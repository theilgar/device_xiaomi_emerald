# Decompiled HyperOS 3 Device Tree Sources (MT6789 emerald)

These device tree sources were reverse engineered and decompiled directly from genuine Xiaomi HyperOS 3 (`OS3.0.307.0.WNFMIXM`) firmware binaries:

* **`mt6789_decompiled.dts`**: Base SoC and board device tree decompiled from `vendor_boot` DTB table using `dtc`.
* **`dtbo_decompiled.dts`**: Overlay device tree decompiled from `dtbo.img` using `dtc`.

## Hardware Specifications Reconstructed
* **Platform:** MediaTek MT6789 (Helio G99 / G99-Ultra)
* **Base Board:** `k6789v1_64` / `emerald`
* **Sub-PMIC & Charger:** Southchip `subpmic_core@61` (SC6601/SC8541) + NuVolta NU2115 charge pump
* **Display & Touch:** Visionox AMOLED (1080x2400) + Goodix GT9916 / FocalTech FTS
