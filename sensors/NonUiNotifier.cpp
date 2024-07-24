/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "NonUiNotifier"

#include <android-base/logging.h>
#include <android/frameworks/sensorservice/1.0/ISensorManager.h>

#include <fcntl.h>
#include <poll.h>
#include <sys/ioctl.h>

#include "xiaomi_touch.h"

#define SENSOR_NAME_XIAOMI_SENSOR_NONUI "xiaomi.sensor.nonui"

using android::sp;
using android::frameworks::sensorservice::V1_0::IEventQueue;
using android::frameworks::sensorservice::V1_0::IEventQueueCallback;
using android::frameworks::sensorservice::V1_0::ISensorManager;
using android::frameworks::sensorservice::V1_0::Result;
using android::hardware::Return;
using android::hardware::Void;
using android::hardware::sensors::V1_0::Event;
using android::hardware::sensors::V1_0::SensorFlagBits;
using android::hardware::sensors::V1_0::SensorInfo;
using android::hardware::sensors::V1_0::SensorType;

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
        int buf[MAX_BUF_SIZE] = {0, Touch_Nonui_Mode, static_cast<int>(e.u.scalar)};
        ioctl(open(TOUCH_DEV_PATH, O_RDWR), TOUCH_IOC_SET_CUR_VALUE, &buf);

        return Void();
    }
};

}  // namespace

int main() {
    Result res;
    sp<IEventQueue> queue;

    sp<ISensorManager> manager = ISensorManager::getService();
    if (manager == nullptr) {
        LOG(ERROR) << "failed to get ISensorManager";
        return EXIT_FAILURE;
    }

    std::vector<SensorInfo> sensorList;
    manager->getSensorList([&sensorList, &res](const auto& l, auto r) {
        sensorList = l;
        res = r;
    });
    if (res != Result::OK) {
        LOG(ERROR) << "failed to get getSensorList";
        return EXIT_FAILURE;
    }
    auto it = std::find_if(sensorList.begin(), sensorList.end(), [](const SensorInfo& sensor) {
        return (sensor.typeAsString == SENSOR_NAME_XIAOMI_SENSOR_NONUI) &&
               (sensor.flags & SensorFlagBits::WAKE_UP);
    });

    int32_t sensorHandle = -1;
    if (it != sensorList.end()) {
        sensorHandle = it->sensorHandle;
    } else {
        LOG(ERROR) << "failed to get wake-up version of nonui sensor";
        return EXIT_FAILURE;
    }

    sensorList.clear();

    manager->createEventQueue(new NonUiSensorCallback(), [&queue, &res](const auto& q, auto r) {
        queue = q;
        res = r;
    });
    if (res != Result::OK) {
        LOG(ERROR) << "failed to create event queue";
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
        if (rc < 0) {
            LOG(ERROR) << "failed to poll, err: " << rc;
            continue;
        }

        for (size_t i = 0; i < paths.size(); ++i) {
            if (pollfds[i].revents & (POLLERR | POLLPRI)) {
                LOG(VERBOSE) << "polled change on " << paths[i];
            }
        }

        bool enabled = false;
        for (size_t i = 0; i < paths.size(); ++i) {
            enabled = enabled || readBool(pollfds[i].fd);
        }
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
