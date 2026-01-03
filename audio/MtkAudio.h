/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <aidl/vendor/mediatek/hardware/audio/BnMtkAudio.h>

namespace aidl::vendor::mediatek::hardware::audio {

using ::aidl::vendor::mediatek::hardware::audio::IAudioParameterChangedCallback;
using ::aidl::vendor::mediatek::hardware::audio::Result;

class MtkAudio : public BnMtkAudio {
  public:
    MtkAudio();
    virtual ~MtkAudio();

    ndk::ScopedAStatus setAudioParameterChangedCallback(
            const std::shared_ptr<IAudioParameterChangedCallback>& callback, int32_t cbkKey,
            Result* pResult) override;

    ndk::ScopedAStatus clearAudioParameterChangedCallback(int32_t cbkKey, Result* pResult) override;
};

} // namespace aidl::vendor::mediatek::hardware::audio
