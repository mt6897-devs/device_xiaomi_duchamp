#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),duchamp)
include $(call all-makefiles-under,$(LOCAL_PATH))

ALL_SYMLINKS := $(addprefix $(TARGET_OUT_ODM)/, $(strip $(shell cat $(DEVICE_PATH)/symlink/list.txt)))
$(ALL_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf $(TARGET_BOARD_PLATFORM)/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(ALL_SYMLINKS)

endif
