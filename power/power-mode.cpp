/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <aidl/android/hardware/power/BnPower.h>
#include <android-base/file.h>
#include <android-base/logging.h>
#include <sys/ioctl.h>

#define SET_CUR_VALUE 0
#define TOUCH_DOUBLETAP_MODE 14
#define TOUCH_FOD_ENABLE 10
#define TOUCH_MAGIC 't'
#define TOUCH_IOC_SETMODE _IO(TOUCH_MAGIC, SET_CUR_VALUE)
#define TOUCH_DEV_PATH "/dev/xiaomi-touch"
#define TOUCH_ID 0

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

bool isDeviceSpecificModeSupported(Mode type, bool* _aidl_return) {
    switch (type) {
        case Mode::DOUBLE_TAP_TO_WAKE:
        case Mode::DISPLAY_INACTIVE:
            *_aidl_return = true;
            return true;
        default:
            return false;
    }
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    switch (type) {
        case Mode::DOUBLE_TAP_TO_WAKE: {
            int fd = open(TOUCH_DEV_PATH, O_RDWR);
            int arg[3] = {TOUCH_ID, TOUCH_DOUBLETAP_MODE, enabled ? 1 : 0};
            ioctl(fd, TOUCH_IOC_SETMODE, &arg);
            close(fd);
            return true;
        }
        case Mode::DISPLAY_INACTIVE: {
            int fd = open(TOUCH_DEV_PATH, O_RDWR);
            int arg[3] = {TOUCH_ID, TOUCH_FOD_ENABLE, enabled ? 1 : 0};
            ioctl(fd, TOUCH_IOC_SETMODE, &arg);
            close(fd);
            return true;
        }
        default:
            return false;
    }
}

}  // namespace pixel
}  // namespace impl
}  // namespace power
}  // namespace hardware
}  // namespace google
}  // namespace aidl
