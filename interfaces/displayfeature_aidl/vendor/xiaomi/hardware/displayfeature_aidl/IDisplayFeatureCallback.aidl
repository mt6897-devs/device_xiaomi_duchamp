//
// SPDX-FileCopyrightText: The LineageOS Project
// SPDX-License-Identifier: Apache-2.0
//

package vendor.xiaomi.hardware.displayfeature_aidl;

@VintfStability
interface IDisplayFeatureCallback {
    oneway void displayfeatureInfoChanged(in int caseId, in int value, in float red,
        in float green, in float blue);
}
