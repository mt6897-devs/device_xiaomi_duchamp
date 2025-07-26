/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "NonUiNotifier"

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/unique_fd.h>

#include <android/frameworks/sensorservice/1.0/ISensorManager.h>
#include <android/frameworks/sensorservice/1.0/types.h>

#include <fcntl.h>
#include <poll.h>
#include <sys/ioctl.h>
#include <string>

#include "xiaomi_touch.h"

#define SENSOR_TYPE_XIAOMI_SENSOR_NONUI 33171027
#define SENSOR_NAME_XIAOMI_SENSOR_NONUI "xiaomi.sensor.nonui"

using ::android::frameworks::sensorservice::V1_0::IEventQueue;
using ::android::frameworks::sensorservice::V1_0::IEventQueueCallback;
using ::android::frameworks::sensorservice::V1_0::ISensorManager;
using ::android::frameworks::sensorservice::V1_0::Result;
using ::android::hardware::Return;
using ::android::hardware::Void;
using ::android::hardware::sensors::V1_0::Event;
using ::android::hardware::sensors::V1_0::SensorType;

using android::sp;

#define TOUCH_DEV_PATH "/dev/xiaomi-touch"
#define TOUCH_MAGIC 'T'
#define TOUCH_IOC_SET_CUR_VALUE _IO(TOUCH_MAGIC, SET_CUR_VALUE)
#define TOUCH_IOC_GET_CUR_VALUE _IO(TOUCH_MAGIC, GET_CUR_VALUE)

namespace {

static bool readBool(int fd) {
    char c;
    int rc;

    rc = lseek(fd, 0, SEEK_SET);
    if (rc) {
        LOG(ERROR) << "failed to seek fd, err: " << rc;
        return false;
    }

    rc = read(fd, &c, sizeof(char));
    if (rc != 1) {
        LOG(ERROR) << "failed to read bool from fd, err: " << rc;
        return false;
    }

    return c != '0';
}

struct NonUiSensorCallback : IEventQueueCallback {
    Return<void> onEvent(const Event& e) {
        /* handle sensor event e */
        LOG(ERROR) << "onEvent scalar: " << e.u.scalar;
        bool nonUi = e.u.scalar == 1;

        // android::base::unique_fd touch_fd_;
        // touch_fd_ = android::base::unique_fd(open(TOUCH_DEV_PATH, O_RDWR));

        int buf[MAX_BUF_SIZE] = {0, Touch_Nonui_Mode, nonUi ? 2 : 0};
        ioctl(open(TOUCH_DEV_PATH, O_RDWR), TOUCH_IOC_SET_CUR_VALUE, &buf);

        return Void();
    }
};

}  // namespace

int main() {
    sp<ISensorManager> manager = ISensorManager::getService();
    if (manager == nullptr) {
        LOG(ERROR) << "failed to get ISensorManager";
    }

    int32_t sensorHandle = -1;
    manager->getDefaultSensor(static_cast<SensorType>(SENSOR_TYPE_XIAOMI_SENSOR_NONUI),
                              [&sensorHandle](const auto& info, auto r) {
                                    sensorHandle = info.sensorHandle;
                              });

    sp<IEventQueue> queue;
    Result res;
    manager->createEventQueue(new NonUiSensorCallback(), [&queue, &res](const auto& q, auto r) {
        queue = q;
        res = r;
    });
    if (res != Result::OK) {
        return EXIT_FAILURE;
    }

    // Enable states of touchscreen sensors
    const std::vector<const char*> paths = {
            "/sys/class/touch/touch_dev/fod_longpress_gesture_enabled",
            "/sys/class/touch/touch_dev/gesture_single_tap_enabled",
            "/sys/class/touch/touch_dev/gesture_double_tap_enabled"};

    pollfd* pollfds = new pollfd[paths.size()];
    for (size_t i = 0; i < paths.size(); ++i) {
        int fd = open(paths[i], O_RDONLY);
        if (fd < 0) {
            LOG(ERROR) << "failed to open " << paths[i] << " , err: " << fd;
            return EXIT_FAILURE;
        }

        pollfds[i].fd = fd;
        pollfds[i].events = POLLERR | POLLPRI;
        pollfds[i].revents = 0;
    }

    while (true) {
        int rc = poll(pollfds, paths.size(), -1);
        LOG(ERROR) << "poll: " << rc;
        if (rc < 0) {
            LOG(ERROR) << "failed to poll, err: " << rc;
            continue;
        }

        for (size_t i = 0; i < paths.size(); ++i) {
            if (pollfds[i].revents & (POLLERR | POLLPRI)) {
                LOG(ERROR) << "Event on " << paths[i];
            }
        }

        bool enabled = false;
        for (size_t i = 0; i < paths.size(); ++i) {
            enabled = enabled || readBool(pollfds[i].fd);
        }
        LOG(ERROR) << "got notified about poll, enabled: " << enabled;
        if (enabled) {
            res = queue->enableSensor(sensorHandle, 20000 /* sample period */, 0 /* latency */);
            if (res != Result::OK) {
                LOG(ERROR) << "failed to enable sensor";
            }
        } else {
            res = queue->disableSensor(sensorHandle);
            if (res != Result::OK) {
                LOG(ERROR) << "failed to disable sensor";
            }
        }
    }

    /*
     * Free the event queue.
     * kernel calls decStrong() on server side implementation of IEventQueue,
     * hence resources (including the callback) are freed as well.
     */
    queue = nullptr;

    // Should never reach this
    return EXIT_SUCCESS;
}
