#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/duchamp

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# A/B
ifneq ($(WITH_GMS),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
TARGET_RO_FILE_SYSTEM_TYPE := ext4
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4
TARGET_RO_FILE_SYSTEM_TYPE := erofs
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.compression.threads=true
endif

PRODUCT_PACKAGES += \
    com.android.hardware.boot \
    android.hardware.boot-service.default_recovery

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=$(TARGET_RO_FILE_SYSTEM_TYPE) \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script

PRODUCT_PACKAGES += \
    create_pl_dev \
    create_pl_dev.recovery

PRODUCT_PACKAGES += \
    e2fsck.vendor_ramdisk \
    fsck.f2fs.vendor_ramdisk \
    linker.vendor_ramdisk \
    resize2fs.vendor_ramdisk \
    tune2fs.vendor_ramdisk

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Audio
TARGET_EXCLUDES_AUDIOFX := true
$(call soong_config_set_bool,android_hardware_audio,skip_speaker_layout_channel_mask_field,true)

PRODUCT_PACKAGES += \
    android.hardware.audio.service.mediatek \
    android.hardware.audio.effect@7.0-impl

PRODUCT_PACKAGES += \
    audio.primary.default \
    audio.r_submix.default \
    audio.usb.default \
    audio_policy.stub

PRODUCT_PACKAGES += \
    MtkInCallService

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(DEVICE_PATH)/configs/audio/audio_policy_configuration_a2dp_offload_enable_cg_enable.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(DEVICE_PATH)/configs/audio/bluetooth_a2dp_offload_ums_offload_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_a2dp_offload_ums_offload_audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth-service.mediatek

# Bootanimation
TARGET_SCREEN_WIDTH := 1220
TARGET_SCREEN_HEIGHT := 2712

# ConsumerIr
PRODUCT_PACKAGES += \
    android.hardware.ir-service.example

# Display
PRODUCT_PACKAGES += \
    android.hardware.memtrack-service.mediatek

PRODUCT_PACKAGES += \
    ANGLE

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/display_id_4627039422300187648.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4627039422300187648.xml

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

# Fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Fingerprint
$(call soong_config_set,XIAOMI_BIOMETRICS_FINGERPRINT,IMPL_VER,V2)
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi \
    libudfpshandler

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.mediatek \
    android.hardware.health-service.mediatek-recovery

# HotwordEnrollement app permissions
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# Linker
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
    $(DEVICE_PATH)/configs/linker.config.json

# Media
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/media,$(TARGET_COPY_OUT_VENDOR)/etc)

# Lineage Health
$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/power_supply/battery/input_suspend)
$(call soong_config_set,lineage_health,charging_control_charging_enabled,0)
$(call soong_config_set,lineage_health,charging_control_charging_disabled,1)
$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)

PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras \
    Tag

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.nxp.mifare.xml

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

$(call inherit-product, hardware/mediatek/overlay/mssi.mk)

PRODUCT_PACKAGES += \
   CarrierConfigOverlayDuchamp \
   FrameworksResOverlayDuchamp \
   PowerOffAlarmOverlayDuchamp \
   NfcOverlayDuchamp \
   SettingsProviderOverlayDuchampPOCO \
   SettingsProviderOverlayDuchampRedmi \
   SettingsResOverlayDuchamp \
   SystemUIOverlayDuchamp

PRODUCT_PACKAGES += \
   LineageApertureOverlayDuchamp \
   LineageSDKOverlayDuchamp \
   LineageSettingsOverlayDuchamp

# Parts
PRODUCT_PACKAGES += \
    XiaomiParts

# Page size
PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnel_migration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnel_migration.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level-2023-03-01.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level-2023-03-01.xml

# Power
$(call soong_config_set,power_libperfmgr,mode_extension_lib, //$(DEVICE_PATH):libperfmgr-ext-xiaomi)

PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr \
    libmtkperf_client_vendor \
    libperfctl_vendor \
    libpowerhalwrap_vendor

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# PowerOffAlarm
PRODUCT_PACKAGES += \
    PowerOffAlarm

# Properties
include $(DEVICE_PATH)/vendor_logtag.mk

# SKU
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/sku/,$(TARGET_COPY_OUT_ODM)/etc)

# Radio
ENABLE_VENDOR_RIL_SERVICE := true

PRODUCT_PACKAGES += \
    vendor_mdota_symlink

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/configs/rsc,$(TARGET_COPY_OUT_VENDOR)/etc/rsc)

# Radio (IMS)
$(call inherit-product, hardware/lineage/compat/frameworks/compat.mk)
$(call inherit-product, hardware/mediatek/frameworks/mediatek-frameworks.mk)

PRODUCT_BOOT_JARS += \
    xiaomi-telephony-stub

PRODUCT_PACKAGES += \
    xiaomi-telephony-stub

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/mediatek-ims-base.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/mediatek-ims-base.xml \
    $(DEVICE_PATH)/configs/permissions/mediatek-ims-common.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/mediatek-ims-common.xml \
    $(DEVICE_PATH)/configs/permissions/mediatek-telecom-common.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/mediatek-telecom-common.xml \
    $(DEVICE_PATH)/configs/permissions/mediatek-telephony-base.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/mediatek-telephony-base.xml \
    $(DEVICE_PATH)/configs/permissions/mediatek-telephony-common.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/mediatek-telephony-common.xml

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-com.mediatek.engineermode.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-com.mediatek.engineermode.xml \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-com.mediatek.ims.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-com.mediatek.ims.xml

# Rootdir
PRODUCT_PACKAGES += \
    fstab.mt6897 \
    fstab.mt6897.vendor_ramdisk \
    init.batterysecret.rc \
    init.connectivity.rc \
    init.fingerprint.rc \
    init.mi_thermald.rc \
    init.mt6897.rc \
    init.mt6897.power.rc \
    init.mt6897.usb.rc \
    init.project.rc \
    init.sensor_2_0.rc \
    ueventd.mtk.rc

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/init.recovery.mt6897.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6897.rc

# Sensors
PRODUCT_PACKAGES += \
   android.hardware.sensors-service.xiaomi-multihal \
   sensors.xiaomi.v2

PRODUCT_PACKAGES += \
   sensors.dynamic_sensor_hal

PRODUCT_COPY_FILES += \
   $(DEVICE_PATH)/configs/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 34

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/mediatek \
    hardware/mediatek/libmtkperf_client \
    hardware/xiaomi

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.pixel \
    thermal_symlinks

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json

# USB
$(call soong_config_set_bool,android_hardware_mediatek_usb,audio_accessory_supported,true)

PRODUCT_PACKAGES += \
    android.hardware.usb-service.mediatek \
    android.hardware.usb.gadget-service.mediatek

# Vendor service manager
PRODUCT_PACKAGES += \
    vndservicemanager

# Vibrator
$(call inherit-product, vendor/qcom/opensource/vibrator/vibrator-vendor-product.mk)

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libwifi-hal-wrapper \
    wpa_supplicant

PRODUCT_PACKAGES += \
    NcmTetheringOverlay

# Inherit the proprietary files
$(call inherit-product, vendor/xiaomi/duchamp/duchamp-vendor.mk)
