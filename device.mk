#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# A/B
ifeq ($(WITH_GMS),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE ?= ext4
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE ?= erofs
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.compression.threads=true
endif

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=$(PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE) \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    com.android.hardware.boot \
    android.hardware.boot-service.default_recovery

PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Shipping API level
BOARD_SHIPPING_API_LEVEL := 34
PRODUCT_SHIPPING_API_LEVEL := 34

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/xiaomi/duchamp/duchamp-vendor.mk)
