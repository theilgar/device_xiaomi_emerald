#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Compiles MT6789 DTB and DTBO from DTS source files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/out"
DTB_OUT_DIR="${OUT_DIR}/dtb"

echo "==> Preparing output directory..."
mkdir -p "${DTB_OUT_DIR}"

DTC_BIN="${DTC:-dtc}"
if ! command -v "${DTC_BIN}" &>/dev/null; then
    echo "Error: Device Tree Compiler (dtc) not found. Please install device-tree-compiler."
    exit 1
fi

echo "==> Compiling MT6789 Device Tree (mt6789_decompiled.dts -> out/dtb/mt6789.dtb)..."
"${DTC_BIN}" -@ -I dts -O dtb -o "${DTB_OUT_DIR}/mt6789.dtb" "${SCRIPT_DIR}/mt6789_decompiled.dts"

echo "==> Compiling DTBO slice (dtbo_decompiled.dts -> /tmp/emerald_dtbo_slice.dtb)..."
"${DTC_BIN}" -@ -I dts -O dtb -o "/tmp/emerald_dtbo_slice.dtb" "${SCRIPT_DIR}/dtbo_decompiled.dts"

echo "==> Packaging DTBO image (out/dtbo.img)..."
python3 "${SCRIPT_DIR}/mkdtboimg.py" create "${OUT_DIR}/dtbo.img" --page_size=2048 "/tmp/emerald_dtbo_slice.dtb"
rm -f "/tmp/emerald_dtbo_slice.dtb"

echo "==> Build complete!"
ls -lh "${DTB_OUT_DIR}/mt6789.dtb" "${OUT_DIR}/dtbo.img"
