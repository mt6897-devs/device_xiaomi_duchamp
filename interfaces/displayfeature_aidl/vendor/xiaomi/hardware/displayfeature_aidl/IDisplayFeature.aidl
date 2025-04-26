//
// SPDX-FileCopyrightText: The LineageOS Project
// SPDX-License-Identifier: Apache-2.0
//

package vendor.xiaomi.hardware.displayfeature_aidl;

import vendor.xiaomi.hardware.displayfeature_aidl.IDisplayFeatureCallback;

@VintfStability
interface IDisplayFeature {
    void notifyBrightness(in int brightness);
    void registerCallback(in int displayId, in IDisplayFeatureCallback callback);
    void sendMessage(in int index, in int value, in String cmd);
    void sendPanelCommand(in String cmd);
    void sendPostProcCommand(in int cmd, in int value);
    void sendRefreshCommand();
    void setFeature(in int displayId, in int caseId, in int modeId, in int cookie);
    void setFunction(in int displayId, in int caseId, in int modeId, in int cookie);
}
