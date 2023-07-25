/*
 * Copyright (C) 2023 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <media/AudioTrack.h>

using namespace android;

extern "C" {
void _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_t20audio_channel_mask_tm20audio_output_flags_tRKNS_2wpINS0_19IAudioTrackCallbackEEEi15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tRKNS_7content22AttributionSourceStateEPK18audio_attributes_tbfi(
    void *thisptr, audio_stream_type_t streamType, uint32_t sampleRate,
    audio_format_t format, audio_channel_mask_t channelMask, size_t frameCount,
    audio_output_flags_t flags,
    const wp<AudioTrack::IAudioTrackCallback> &callback,
    int32_t notificationFrames, audio_session_t sessionId,
    AudioTrack::transfer_type transferType,
    const audio_offload_info_t *offloadInfo,
    const AttributionSourceState &attributionSource,
    const audio_attributes_t *pAttributes, bool doNotReconnect,
    float maxRequiredSpeed, audio_port_handle_t selectedDeviceId);

void _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_t20audio_channel_mask_tm20audio_output_flags_tRKNS_2wpINS0_19IAudioTrackCallbackEEEi15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tRKNS_7content22AttributionSourceStateEPK18audio_attributes_tbfiRKNSt3__112basic_stringIcNSM_11char_traitsIcEENSM_9allocatorIcEEEE(
    void *thisptr, audio_stream_type_t streamType, uint32_t sampleRate,
    audio_format_t format, audio_channel_mask_t channelMask, size_t frameCount,
    audio_output_flags_t flags,
    const wp<AudioTrack::IAudioTrackCallback> &callback,
    int32_t notificationFrames, audio_session_t sessionId,
    AudioTrack::transfer_type transferType,
    const audio_offload_info_t *offloadInfo,
    const AttributionSourceState &attributionSource,
    const audio_attributes_t *pAttributes, bool doNotReconnect,
    float maxRequiredSpeed, audio_port_handle_t selectedDeviceId,
    const std::string& /* unknown */) {
  _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_t20audio_channel_mask_tm20audio_output_flags_tRKNS_2wpINS0_19IAudioTrackCallbackEEEi15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tRKNS_7content22AttributionSourceStateEPK18audio_attributes_tbfi(
      thisptr, streamType, sampleRate, format, channelMask, frameCount, flags,
      callback, notificationFrames, sessionId, transferType, offloadInfo,
      attributionSource, pAttributes, doNotReconnect, maxRequiredSpeed,
      selectedDeviceId);
}
}
