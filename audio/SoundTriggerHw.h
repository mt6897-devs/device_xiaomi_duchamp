/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <aidl/android/hardware/soundtrigger3/BnSoundTriggerHw.h>

namespace aidl::android::hardware::soundtrigger3 {

using ::aidl::android::media::soundtrigger::ModelParameter;
using ::aidl::android::media::soundtrigger::ModelParameterRange;
using ::aidl::android::media::soundtrigger::PhraseSoundModel;
using ::aidl::android::media::soundtrigger::Properties;
using ::aidl::android::media::soundtrigger::RecognitionConfig;
using ::aidl::android::media::soundtrigger::SoundModel;

class SoundTriggerHw : public BnSoundTriggerHw {
  public:
    SoundTriggerHw();
    virtual ~SoundTriggerHw();

    ndk::ScopedAStatus getProperties(Properties* _aidl_return) override;

    ndk::ScopedAStatus registerGlobalCallback(
            const std::shared_ptr<ISoundTriggerHwGlobalCallback>& callback) override;

    ndk::ScopedAStatus loadSoundModel(const SoundModel& soundModel,
                                      const std::shared_ptr<ISoundTriggerHwCallback>& callback,
                                      int32_t* _aidl_return) override;

    ndk::ScopedAStatus loadPhraseSoundModel(
            const PhraseSoundModel& soundModel,
            const std::shared_ptr<ISoundTriggerHwCallback>& callback,
            int32_t* _aidl_return) override;

    ndk::ScopedAStatus unloadSoundModel(int32_t modelHandle) override;

    ndk::ScopedAStatus startRecognition(int32_t modelHandle, int32_t deviceHandle, int32_t ioHandle,
                                        const RecognitionConfig& config) override;

    ndk::ScopedAStatus stopRecognition(int32_t modelHandle) override;

    ndk::ScopedAStatus forceRecognitionEvent(int32_t modelHandle) override;

    ndk::ScopedAStatus queryParameter(int32_t modelHandle, ModelParameter modelParam,
                                      std::optional<ModelParameterRange>* _aidl_return) override;

    ndk::ScopedAStatus getParameter(int32_t modelHandle, ModelParameter modelParam,
                                    int32_t* _aidl_return) override;

    ndk::ScopedAStatus setParameter(int32_t modelHandle, ModelParameter modelParam,
                                    int32_t value) override;
};

}  // namespace aidl::android::hardware::soundtrigger3
