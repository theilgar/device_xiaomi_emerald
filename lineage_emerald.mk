#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# CAS HAL: Eradicate deprecated HIDL CAS for FCM 202504
TARGET_REQUIRES_HIDL_CAS_HAL := false

# Enable GMS / Google Apps
WITH_GMS := true
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from emerald device
$(call inherit-product, device/xiaomi/emerald/device.mk)

PRODUCT_DEVICE := emerald
PRODUCT_NAME := lineage_emerald
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 23117RA68G
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_BRAND_FOR_ATTESTATION := $(PRODUCT_BRAND)
PRODUCT_DEVICE_FOR_ATTESTATION := $(PRODUCT_DEVICE)
PRODUCT_MODEL_FOR_ATTESTATION := $(PRODUCT_MODEL)
PRODUCT_NAME_FOR_ATTESTATION := emerald_global
PRODUCT_MANUFACTURER_FOR_ATTESTATION := $(PRODUCT_MANUFACTURER)

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="missi-user 16 BP2A.250605.031.A3 OS3.0.305.0.WNFMIXM release-keys" \
    BuildFingerprint=Redmi/miodm_emerald/emerald:16/BP2A.250605.031.A3/OS3.0.305.0.WNFMIXM:user/release-keys
