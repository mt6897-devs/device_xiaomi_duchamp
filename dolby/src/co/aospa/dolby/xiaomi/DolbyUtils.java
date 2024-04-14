/*
 * Copyright (C) 2023-24 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package co.aospa.dolby.xiaomi;

import android.content.Context;
import android.content.SharedPreferences;
import android.media.AudioAttributes;
import android.media.AudioDeviceAttributes;
import android.media.AudioDeviceCallback;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.media.AudioManager.AudioPlaybackCallback;
import android.media.AudioPlaybackConfiguration;
import android.media.session.MediaSessionManager;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;

import co.aospa.dolby.xiaomi.DolbyConstants.DsParam;
import co.aospa.dolby.xiaomi.R;

import java.util.Arrays;
import java.util.List;

public final class DolbyUtils {

    private static final String TAG = "DolbyUtils";
    private static final int EFFECT_PRIORITY = 100;
    private static final int VOLUME_LEVELER_AMOUNT = 2;

    private static final AudioAttributes ATTRIBUTES_MEDIA = new AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .build();

    private static DolbyUtils mInstance;
    private DolbyAtmos mDolbyAtmos;
    private Context mContext;
    private AudioManager mAudioManager;
    private Handler mHandler = new Handler();
    private boolean mCallbacksRegistered = false;

    // Restore current profile on every media session
    private final AudioPlaybackCallback mPlaybackCallback = new AudioPlaybackCallback() {
        @Override
        public void onPlaybackConfigChanged(List<AudioPlaybackConfiguration> configs) {
            boolean isPlaying = configs.stream().anyMatch(
                    c -> c.getPlayerState() == AudioPlaybackConfiguration.PLAYER_STATE_STARTED);
            dlog("onPlaybackConfigChanged isPlaying=" + isPlaying);
            if (isPlaying)
                setCurrentProfile();
        }
    };

    // Restore current profile on audio device change
    private final AudioDeviceCallback mAudioDeviceCallback = new AudioDeviceCallback() {
        public void onAudioDevicesAdded(AudioDeviceInfo[] addedDevices) {
            dlog("onAudioDevicesAdded");
            setCurrentProfile();
        }

        public void onAudioDevicesRemoved(AudioDeviceInfo[] removedDevices) {
            dlog("onAudioDevicesRemoved");
            setCurrentProfile();
        }
    };

    private DolbyUtils(Context context) {
        mContext = context;
        mDolbyAtmos = new DolbyAtmos(EFFECT_PRIORITY, 0);
        mAudioManager = context.getSystemService(AudioManager.class);
        dlog("initalized");
    }

    public static synchronized DolbyUtils getInstance(Context context) {
        if (mInstance == null) {
            mInstance = new DolbyUtils(context);
        }
        return mInstance;
    }

    public void onBootCompleted() {
        dlog("onBootCompleted");

        // Restore current profile now and on certain audio changes.
        final boolean dsOn = getDsOn();
        mDolbyAtmos.setEnabled(dsOn);
        registerCallbacks(dsOn);
        if (dsOn)
            setCurrentProfile();

        // Restore speaker virtualizer, because for some reason it isn't
        // enabled automatically at boot.
        final AudioDeviceAttributes device =
                mAudioManager.getDevicesForAttributes(ATTRIBUTES_MEDIA).get(0);
        final boolean isOnSpeaker = (device.getType() == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER);
        final boolean spkVirtEnabled = getSpeakerVirtualizerEnabled();
        dlog("isOnSpeaker=" + isOnSpeaker + " spkVirtEnabled=" + spkVirtEnabled);
        if (isOnSpeaker && spkVirtEnabled) {
            setSpeakerVirtualizerEnabled(false);
            setSpeakerVirtualizerEnabled(true);
            Log.i(TAG, "re-enabled speaker virtualizer");
        }
    }

    private void checkEffect() {
        if (!mDolbyAtmos.hasControl()) {
            Log.w(TAG, "lost control, recreating effect");
            mDolbyAtmos.release();
            mDolbyAtmos = new DolbyAtmos(EFFECT_PRIORITY, 0);
        }
    }

    private void setCurrentProfile() {
        if (!getDsOn()) {
            dlog("setCurrentProfile: skip, dolby is off");
            return;
        }
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(mContext);
        int profile = Integer.parseInt(prefs.getString(
                DolbySettingsFragment.PREF_PROFILE, "0" /*dynamic*/));
        setProfile(profile);
    }

    private void registerCallbacks(boolean register) {
        dlog("registerCallbacks(" + register + ") mCallbacksRegistered=" + mCallbacksRegistered);
        if (register && !mCallbacksRegistered) {
            mAudioManager.registerAudioPlaybackCallback(mPlaybackCallback, mHandler);
            mAudioManager.registerAudioDeviceCallback(mAudioDeviceCallback, mHandler);
            mCallbacksRegistered = true;
        } else if (!register && mCallbacksRegistered) {
            mAudioManager.unregisterAudioPlaybackCallback(mPlaybackCallback);
            mAudioManager.unregisterAudioDeviceCallback(mAudioDeviceCallback);
            mCallbacksRegistered = false;
        }
    }

    public void setDsOn(boolean on) {
        checkEffect();
        dlog("setDsOn: " + on);
        mDolbyAtmos.setDsOn(on);
        registerCallbacks(on);
        if (on)
            setCurrentProfile();
    }

    public boolean getDsOn() {
        boolean on = mDolbyAtmos.getDsOn();
        dlog("getDsOn: " + on);
        return on;
    }

    public void setProfile(int index) {
        checkEffect();
        dlog("setProfile: " + index);
        mDolbyAtmos.setProfile(index);
    }

    public int getProfile() {
        int profile = mDolbyAtmos.getProfile();
        dlog("getProfile: " + profile);
        return profile;
    }

    public String getProfileName() {
        String profile = Integer.toString(mDolbyAtmos.getProfile());
        List<String> profiles = Arrays.asList(mContext.getResources().getStringArray(
                R.array.dolby_profile_values));
        int profileIndex = profiles.indexOf(profile);
        dlog("getProfileName: profile=" + profile + " index=" + profileIndex);
        return profileIndex == -1 ? null : mContext.getResources().getStringArray(
                R.array.dolby_profile_entries)[profileIndex];
    }

    public void resetProfileSpecificSettings() {
        checkEffect();
        mDolbyAtmos.resetProfileSpecificSettings();
    }

    public void setPreset(String preset) {
        checkEffect();
        int[] gains = Arrays.stream(preset.split(",")).mapToInt(Integer::parseInt).toArray();
        dlog("setPreset: " + Arrays.toString(gains));
        mDolbyAtmos.setDapParameter(DsParam.GEQ_BAND_GAINS, gains);
    }

    public String getPreset() {
        int[] gains = mDolbyAtmos.getDapParameter(DsParam.GEQ_BAND_GAINS);
        dlog("getPreset: " + Arrays.toString(gains));
        String[] preset = Arrays.stream(gains).mapToObj(String::valueOf).toArray(String[]::new);
        return String.join(",", preset);
    }

    public void setHeadphoneVirtualizerEnabled(boolean enable) {
        checkEffect();
        dlog("setHeadphoneVirtualizerEnabled: " + enable);
        mDolbyAtmos.setDapParameterBool(DsParam.HEADPHONE_VIRTUALIZER, enable);
    }

    public boolean getHeadphoneVirtualizerEnabled() {
        boolean enabled = mDolbyAtmos.getDapParameterBool(DsParam.HEADPHONE_VIRTUALIZER);
        dlog("getHeadphoneVirtualizerEnabled: " + enabled);
        return enabled;
    }

    public void setSpeakerVirtualizerEnabled(boolean enable) {
        checkEffect();
        dlog("setSpeakerVirtualizerEnabled: " + enable);
        mDolbyAtmos.setDapParameterBool(DsParam.SPEAKER_VIRTUALIZER, enable);
    }

    public boolean getSpeakerVirtualizerEnabled() {
        boolean enabled = mDolbyAtmos.getDapParameterBool(DsParam.SPEAKER_VIRTUALIZER);
        dlog("getSpeakerVirtualizerEnabled: " + enabled);
        return enabled;
    }

    public void setStereoWideningAmount(int amount) {
        checkEffect();
        dlog("setStereoWideningAmount: " + amount);
        mDolbyAtmos.setDapParameterInt(DsParam.STEREO_WIDENING_AMOUNT, amount);
    }

    public int getStereoWideningAmount() {
        int amount = mDolbyAtmos.getDapParameterInt(DsParam.STEREO_WIDENING_AMOUNT);
        dlog("getStereoWideningAmount: " + amount);
        return amount;
    }

    public void setDialogueEnhancerAmount(int amount) {
        checkEffect();
        dlog("setDialogueEnhancerAmount: " + amount);
        mDolbyAtmos.setDapParameterBool(DsParam.DIALOGUE_ENHANCER_ENABLE, amount > 0);
        mDolbyAtmos.setDapParameterInt(DsParam.DIALOGUE_ENHANCER_AMOUNT, amount);
    }

    public int getDialogueEnhancerAmount() {
        boolean enabled = mDolbyAtmos.getDapParameterBool(
                DsParam.DIALOGUE_ENHANCER_ENABLE);
        int amount = enabled ? mDolbyAtmos.getDapParameterInt(
                DsParam.DIALOGUE_ENHANCER_AMOUNT) : 0;
        dlog("getDialogueEnhancerAmount: " + enabled + " amount=" + amount);
        return amount;
    }

    public void setBassEnhancerEnabled(boolean enable) {
        checkEffect();
        dlog("setBassEnhancerEnabled: " + enable);
        mDolbyAtmos.setDapParameterBool(DsParam.BASS_ENHANCER_ENABLE, enable);
    }

    public boolean getBassEnhancerEnabled() {
        boolean enabled = mDolbyAtmos.getDapParameterBool(DsParam.BASS_ENHANCER_ENABLE);
        dlog("getBassEnhancerEnabled: " + enabled);
        return enabled;
    }

    public void setVolumeLevelerEnabled(boolean enable) {
        checkEffect();
        dlog("setVolumeLevelerEnabled: " + enable);
        mDolbyAtmos.setDapParameterBool(DsParam.VOLUME_LEVELER_ENABLE, enable);
        mDolbyAtmos.setDapParameterInt(DsParam.VOLUME_LEVELER_AMOUNT,
                enable ? VOLUME_LEVELER_AMOUNT : 0);
    }

    public boolean getVolumeLevelerEnabled() {
        boolean enabled = mDolbyAtmos.getDapParameterBool(DsParam.VOLUME_LEVELER_ENABLE);
        int amount = mDolbyAtmos.getDapParameterInt(DsParam.VOLUME_LEVELER_AMOUNT);
        dlog("getVolumeLevelerEnabled: " + enabled + " amount=" + amount);
        return enabled && (amount == VOLUME_LEVELER_AMOUNT);
    }

    private static void dlog(String msg) {
        if (Log.isLoggable(TAG, Log.DEBUG)) {
            Log.d(TAG, msg);
        }
    }
}
