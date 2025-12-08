/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package vendor.mediatek.hardware.audio;

@VintfStability
interface IAudioParameterChangedCallback {
    void onAudioParameterChanged(in String keyValuePairs);
}
