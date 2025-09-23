/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.display

import android.os.IBinder
import android.os.ServiceManager
import android.util.Log
import vendor.xiaomi.hardware.displayfeature_aidl.IDisplayFeature

object DisplayFeatureWrapper {

    private const val TAG = "DisplayFeatureWrapper"
    //private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)
    private val DEBUG = true

    @Volatile private var displayFeature: IDisplayFeature? = null

    private val deathRecipient =
        IBinder.DeathRecipient {
            if (DEBUG) Log.d(TAG, "serviceDied")
            displayFeature = null
        }

    @Synchronized
    private fun getDisplayFeature(): IDisplayFeature? =
        displayFeature
            ?: runCatching {
                val fqName = "${IDisplayFeature.DESCRIPTOR}/default"
                val binder = android.os.Binder.allowBlocking(
                    android.os.ServiceManager.waitForDeclaredService(fqName)
                )
                IDisplayFeature.Stub.asInterface(binder).apply {
                    asBinder().linkToDeath(deathRecipient, 0)
                }
            }
            .onSuccess { displayFeature = it }
            .onFailure { e -> Log.e(TAG, "getDisplayFeature failed!", e) }
            .getOrNull()

    fun setFeature(mode: Int, value: Int, cookie: Int) {
        val displayFeature =
            getDisplayFeature()
                ?: run {
                    Log.e(TAG, ": displayFeature is null!")
                    return
                }
        if (DEBUG) Log.d(TAG, "setFeature: mode=$mode, value=$value, cookie=$cookie")
        runCatching { displayFeature.setFeature(/*displayId*/ 0, mode, value, cookie) }
            .onFailure { e -> Log.e(TAG, "setFeature failed!", e) }
    }
}
