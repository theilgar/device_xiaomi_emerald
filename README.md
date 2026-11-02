# Android Device Tree for Xiaomi POCO M6 Pro 4G / Redmi Note 13 Pro 4G / Redmi Note 14S (emerald)

```
#
# Copyright (C) 2025-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
```

## Device Specifications

| Feature | Details |
| :--- | :--- |
| **Chipset** | MediaTek MT6789 (Helio G99 / Helio G99-Ultra) |
| **CPU** | Octa-core (2x 2.2 GHz Cortex-A76 & 6x 2.0 GHz Cortex-A55) |
| **GPU** | ARM Mali-G57 MC2 |
| **Architecture** | ARM64 (aarch64) |
| **Kernel** | Linux 6.12.30 GKI (HyperOS 3 Android 16 base) |
| **Display** | 1080 x 2400 AMOLED (120Hz) |
| **Storage & RAM** | UFS 2.2 / LPDDR4X |

## How to Sync & Build

### 1. Local Manifest Setup
Copy `manifest/emerald.xml` to your ROM working tree:
```bash
mkdir -p .repo/local_manifests
cp device/xiaomi/emerald/manifest/emerald.xml .repo/local_manifests/
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2. Build Targets
* **For Pure AOSP / AOSP-based ROMs:**
```bash
source build/envsetup.sh
lunch aosp_emerald-userdebug
m bacon
```

* **For LineageOS:**
```bash
source build/envsetup.sh
lunch lineage_emerald-userdebug
m bacon
```
