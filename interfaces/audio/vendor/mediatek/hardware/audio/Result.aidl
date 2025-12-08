/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package vendor.mediatek.hardware.audio;

@Backing(type="int") @VintfStability
enum Result {
    OK = 0,
    ERROR = 1,
    NOT_INITIALIZED = 2,
    INVALID_ARGUMENTS = 3,
    NOT_SUPPORTED = 4,
}
