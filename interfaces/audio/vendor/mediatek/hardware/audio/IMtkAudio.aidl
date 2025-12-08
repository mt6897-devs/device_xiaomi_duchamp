/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package vendor.mediatek.hardware.audio;

import vendor.mediatek.hardware.audio.IAudioParameterChangedCallback;
import vendor.mediatek.hardware.audio.Result;

@VintfStability
interface IMtkAudio {
    Result setAudioParameterChangedCallback(in IAudioParameterChangedCallback callback, in int callbackKey);
    Result clearAudioParameterChangedCallback(in int callbackKey);
}
