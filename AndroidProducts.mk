#
# Copyright (C) 2025-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aosp_emerald.mk \
    $(LOCAL_DIR)/lineage_emerald.mk

COMMON_LUNCH_CHOICES := \
    aosp_emerald-user \
    aosp_emerald-userdebug \
    aosp_emerald-eng \
    lineage_emerald-user \
    lineage_emerald-userdebug \
    lineage_emerald-eng
