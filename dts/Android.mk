#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

# Build mt6789.dtb and dtbo.img from DTS source
.PHONY: emerald_dts_build
emerald_dts_build:
	@echo "Building emerald DTB and DTBO from DTS sources..."
	$(LOCAL_PATH)/build_dt.sh
