/*
 * Copyright (C) 2023-24 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package co.aospa.dolby.xiaomi

import android.media.AudioAttributes
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Bundle
import android.os.Handler
import android.widget.CompoundButton
import android.widget.CompoundButton.OnCheckedChangeListener
import android.widget.Toast
import androidx.preference.ListPreference
import androidx.preference.Preference
import androidx.preference.Preference.OnPreferenceChangeListener
import androidx.preference.PreferenceFragment
import androidx.preference.SwitchPreferenceCompat
import co.aospa.dolby.xiaomi.DolbyConstants.Companion.dlog
import co.aospa.dolby.xiaomi.R
import com.android.settingslib.widget.MainSwitchPreference

class DolbySettingsFragment : PreferenceFragment(),
    OnPreferenceChangeListener, CompoundButton.OnCheckedChangeListener {

    private val switchBar by lazy {
        findPreference<MainSwitchPreference>(DolbyConstants.PREF_ENABLE)!!
    }
    private val profilePref by lazy {
        findPreference<ListPreference>(DolbyConstants.PREF_PROFILE)!!
    }
    private val presetPref by lazy {
        findPreference<ListPreference>(DolbyConstants.PREF_PRESET)!!
    }
    private val stereoPref by lazy {
        findPreference<ListPreference>(DolbyConstants.PREF_STEREO)!!
    }
    private val dialoguePref by lazy {
        findPreference<ListPreference>(DolbyConstants.PREF_DIALOGUE)!!
    }
    private val bassPref by lazy {
        findPreference<SwitchPreferenceCompat>(DolbyConstants.PREF_BASS)!!
    }
    private val virtPref by lazy {
        findPreference<SwitchPreferenceCompat>(DolbyConstants.PREF_VIRTUALIZER)!!
    }
    private val volumePref by lazy {
        findPreference<SwitchPreferenceCompat>(DolbyConstants.PREF_VOLUME)!!
    }
    private val resetPref by lazy {
        findPreference<Preference>(DolbyConstants.PREF_RESET)!!
    }

    private val dolbyController by lazy { DolbyController.getInstance(context) }
    private val audioManager by lazy { context.getSystemService(AudioManager::class.java) }
    private val handler = Handler()

    private var isOnSpeaker = true
        set(value) {
            if (field == value) return
            field = value
            dlog(TAG, "setIsOnSpeaker($value)")
            updateProfileSpecificPrefs()
        }

    private val audioDeviceCallback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
            dlog(TAG, "onAudioDevicesAdded")
            updateSpeakerState()
        }

        override fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) {
            dlog(TAG, "onAudioDevicesRemoved")
            updateSpeakerState()
        }
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        dlog(TAG, "onCreatePreferences")
        addPreferencesFromResource(R.xml.dolby_settings)

        val dsOn = dolbyController.dsOn
        switchBar.addOnSwitchChangeListener(this)
        switchBar.setChecked(dsOn)

        profilePref.onPreferenceChangeListener = this
        profilePref.setEnabled(dsOn)

        val profile = dolbyController.profile
        profilePref.apply {
            if (entryValues.contains(profile.toString())) {
                summary = "%s"
                value = profile.toString()
            } else {
                summary = context.getString(R.string.dolby_unknown)
            }
        }

        presetPref.onPreferenceChangeListener = this
        virtPref.onPreferenceChangeListener = this
        stereoPref.onPreferenceChangeListener = this
        dialoguePref.onPreferenceChangeListener = this
        bassPref.onPreferenceChangeListener = this
        volumePref.onPreferenceChangeListener = this

        resetPref.setOnPreferenceClickListener {
            dolbyController.resetProfileSpecificSettings()
            updateProfileSpecificPrefs()
            Toast.makeText(
                context,
                context.getString(R.string.dolby_reset_profile_toast, profilePref.summary),
                Toast.LENGTH_SHORT
            ).show()
            true
        }

        audioManager.registerAudioDeviceCallback(audioDeviceCallback, handler)
        updateSpeakerState()
        updateProfileSpecificPrefs()
    }

    override fun onDestroyView() {
        dlog(TAG, "onDestroyView")
        audioManager.unregisterAudioDeviceCallback(audioDeviceCallback)
        super.onDestroyView()
    }

    override fun onPreferenceChange(preference: Preference, newValue: Any): Boolean {
        dlog(TAG, "onPreferenceChange: key=${preference.key} value=$newValue")
        when (preference.key) {
            DolbyConstants.PREF_PROFILE -> {
                dolbyController.profile = newValue.toString().toInt()
                updateProfileSpecificPrefs()
            }

            DolbyConstants.PREF_PRESET -> {
                dolbyController.preset = newValue.toString()
            }

            DolbyConstants.PREF_VIRTUALIZER -> {
                if (isOnSpeaker)
                    dolbyController.speakerVirtEnabled = newValue as Boolean
                else
                    dolbyController.headphoneVirtEnabled = newValue as Boolean
            }

            DolbyConstants.PREF_STEREO -> {
                dolbyController.stereoWideningAmount = newValue.toString().toInt()
            }

            DolbyConstants.PREF_DIALOGUE -> {
                dolbyController.dialogueEnhancerAmount = newValue.toString().toInt()
            }

            DolbyConstants.PREF_BASS -> {
                dolbyController.bassEnhancerEnabled = newValue as Boolean
            }

            DolbyConstants.PREF_VOLUME -> {
                dolbyController.volumeLevelerEnabled = newValue as Boolean
            }

            else -> return false
        }
        return true
    }

    override fun onCheckedChanged(buttonView: CompoundButton, isChecked: Boolean) {
        dlog(TAG, "onCheckedChanged($isChecked)")
        dolbyController.dsOn = isChecked
        profilePref.setEnabled(isChecked)
        updateProfileSpecificPrefs()
    }

    private fun updateSpeakerState() {
        val device = audioManager.getDevicesForAttributes(ATTRIBUTES_MEDIA)[0]
        isOnSpeaker = (device.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER)
    }

    private fun updateProfileSpecificPrefs() {
        val unknownRes = context.getString(R.string.dolby_unknown)
        val headphoneRes = context.getString(R.string.dolby_connect_headphones)
        val dsOn = dolbyController.dsOn
        val currentProfile = dolbyController.profile

        dlog(
            TAG, "updateProfileSpecificPrefs: dsOn=$dsOn currentProfile=$currentProfile"
                    + " isOnSpeaker=$isOnSpeaker"
        )

        val enable = dsOn && (currentProfile != -1)
        presetPref.setEnabled(enable)
        virtPref.setEnabled(enable)
        dialoguePref.setEnabled(enable)
        volumePref.setEnabled(enable)
        resetPref.setEnabled(enable)
        stereoPref.setEnabled(enable && !isOnSpeaker)
        bassPref.setEnabled(enable && !isOnSpeaker)

        if (!enable) return

        val preset = dolbyController.preset
        presetPref.apply {
            if (entryValues.contains(preset)) {
                summary = "%s"
                value = preset
            } else {
                summary = unknownRes
            }
        }

        val deValue = dolbyController.dialogueEnhancerAmount.toString()
        dialoguePref.apply {
            if (entryValues.contains(deValue)) {
                summary = "%s"
                value = deValue
            } else {
                summary = unknownRes
            }
        }

        virtPref.setChecked(if (isOnSpeaker) {
            dolbyController.speakerVirtEnabled
        } else {
            dolbyController.headphoneVirtEnabled
        })

        volumePref.setChecked(dolbyController.volumeLevelerEnabled)

        // below prefs are not enabled on loudspeaker
        if (isOnSpeaker) {
            stereoPref.summary = headphoneRes
            bassPref.summary = headphoneRes
            return
        }

        val swValue = dolbyController.stereoWideningAmount.toString()
        stereoPref.apply {
            if (entryValues.contains(swValue)) {
                summary = "%s"
                value = swValue
            } else {
                summary = unknownRes
            }
        }

        bassPref.apply {
            setChecked(dolbyController.bassEnhancerEnabled)
            summary = null
        }
    }

    companion object {
        private const val TAG = "DolbySettingsFragment"
        private val ATTRIBUTES_MEDIA = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .build()
    }
}
