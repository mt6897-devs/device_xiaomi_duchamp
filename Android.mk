#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),duchamp)
include $(call all-makefiles-under,$(LOCAL_PATH))

MDOTA_SYMLINK := $(TARGET_OUT_VENDOR)/etc/mdota
$(MDOTA_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf /mnt/vendor/mdota $@

ALL_DEFAULT_INSTALLED_MODULES += $(MDOTA_SYMLINK)

endif
