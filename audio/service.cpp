/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "mtkaudiohalservice"

#include <signal.h>
#include <string>
#include <vector>

#include <android/binder_process.h>
#include <binder/ProcessState.h>
#include <cutils/properties.h>
#include <dlfcn.h>
#include <hidl/HidlTransportSupport.h>
#include <hidl/LegacySupport.h>
#include <hwbinder/ProcessState.h>

using namespace android::hardware;
using android::OK;

using InterfacesList = std::vector<std::string>;

/** Try to register the provided factories in the provided order.
 *  If any registers successfully, do not register any other and return true.
 *  If all fail, return false.
 */
template <class Iter>
static bool registerPassthroughServiceImplementations(Iter first, Iter last) {
    for (; first != last; ++first) {
        if (registerPassthroughServiceImplementation(*first) == OK) {
            return true;
        }
    }
    return false;
}

static bool registerExternalServiceImplementation(const std::string& libName,
                                                  const std::string& funcName) {
    constexpr int dlMode = RTLD_LAZY;
    void* handle = nullptr;
    dlerror();  // clear
    auto libPath = libName + ".so";
    handle = dlopen(libPath.c_str(), dlMode);
    if (handle == nullptr) {
        const char* error = dlerror();
        ALOGE("Failed to dlopen %s: %s", libPath.c_str(),
              error != nullptr ? error : "unknown error");
        return false;
    }
    binder_status_t (*factoryFunction)();
    *(void**)(&factoryFunction) = dlsym(handle, funcName.c_str());
    if (!factoryFunction) {
        const char* error = dlerror();
        ALOGE("Factory function %s not found in libName %s: %s", funcName.c_str(), libPath.c_str(),
              error != nullptr ? error : "unknown error");
        dlclose(handle);
        return false;
    }
    return ((*factoryFunction)() == STATUS_OK);
}

int main(int /* argc */, char* /* argv */[]) {
    signal(SIGPIPE, SIG_IGN);

    if (::android::ProcessState::isVndservicemanagerEnabled()) {
        ::android::ProcessState::initWithDriver("/dev/vndbinder");
        ::android::ProcessState::self()->startThreadPool();
    }

    ABinderProcess_setThreadPoolMaxThreadCount(1);
    ABinderProcess_startThreadPool();

    const int32_t defaultValue = -1;
    int32_t value =
            property_get_int32("persist.vendor.audio.service.hwbinder.size_kbyte", defaultValue);
    if (value != defaultValue) {
        ALOGD("Configuring hwbinder with mmap size %d KBytes", value);
        ProcessState::initWithMmapSize(static_cast<size_t>(value) * 1024);
    }
    configureRpcThreadpool(16, true /*callerWillJoin*/);

    // Automatic formatting tries to compact the lines, making them less readable
    // clang-format off
    const std::vector<InterfacesList> mandatoryInterfaces = {
        {
            "Audio Core API",
            "android.hardware.audio@7.1::IDevicesFactory",
            "android.hardware.audio@7.0::IDevicesFactory",
            "android.hardware.audio@6.0::IDevicesFactory",
            "android.hardware.audio@5.0::IDevicesFactory",
            "android.hardware.audio@4.0::IDevicesFactory",
        },
        {
            "Audio Effect API",
            "android.hardware.audio.effect@7.0::IEffectsFactory",
            "android.hardware.audio.effect@6.0::IEffectsFactory",
            "android.hardware.audio.effect@5.0::IEffectsFactory",
            "android.hardware.audio.effect@4.0::IEffectsFactory",
        }
    };

    const std::vector<InterfacesList> optionalInterfaces = {
        {
            "Soundtrigger API",
            "android.hardware.soundtrigger@2.3::ISoundTriggerHw",
            "android.hardware.soundtrigger@2.2::ISoundTriggerHw",
            "android.hardware.soundtrigger@2.1::ISoundTriggerHw",
            "android.hardware.soundtrigger@2.0::ISoundTriggerHw",
        },
        {
            "Bluetooth Audio API",
            "android.hardware.bluetooth.audio@2.2::IBluetoothAudioProvidersFactory",
            "android.hardware.bluetooth.audio@2.1::IBluetoothAudioProvidersFactory",
            "android.hardware.bluetooth.audio@2.0::IBluetoothAudioProvidersFactory",
        },
        // remove the old HIDL when Bluetooth Audio Hal V2 has offloading supported
        {
            "Bluetooth Audio Offload API",
            "android.hardware.bluetooth.a2dp@1.0::IBluetoothAudioOffload"
        }
    };

    const std::vector<std::pair<std::string,std::string>> optionalInterfaceSharedLibs = {
        {
            "android.hardware.bluetooth.audio-impl",
            "createIBluetoothAudioProviderFactory",
        },
        {
            "android.hardware.audio.sounddose-vendor-impl",
            "createISoundDoseFactory",
        },
    };
    // clang-format on

    for (const auto& listIter : mandatoryInterfaces) {
        auto iter = listIter.begin();
        const std::string& interfaceFamilyName = *iter++;
        LOG_ALWAYS_FATAL_IF(!registerPassthroughServiceImplementations(iter, listIter.end()),
                            "Could not register %s", interfaceFamilyName.c_str());
    }

    for (const auto& listIter : optionalInterfaces) {
        auto iter = listIter.begin();
        const std::string& interfaceFamilyName = *iter++;
        ALOGW_IF(!registerPassthroughServiceImplementations(iter, listIter.end()),
                 "Could not register %s", interfaceFamilyName.c_str());
    }

    for (const auto& interfacePair : optionalInterfaceSharedLibs) {
        const std::string& libraryName = interfacePair.first;
        const std::string& interfaceLoaderFuncName = interfacePair.second;
        if (registerExternalServiceImplementation(libraryName, interfaceLoaderFuncName)) {
            ALOGI("%s() from %s success", interfaceLoaderFuncName.c_str(), libraryName.c_str());
        } else {
            ALOGW("%s() from %s failed", interfaceLoaderFuncName.c_str(), libraryName.c_str());
        }
    }

    joinRpcThreadpool();
}
