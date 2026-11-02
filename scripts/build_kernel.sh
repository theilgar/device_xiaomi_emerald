#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Builds Linux 6.12 GKI kernel from source for Xiaomi emerald (MT6789)
#

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_SOURCE:-${ROOT_DIR}/../../kernel/common}"
OUT_DIR="${KERNEL_OUT:-${ROOT_DIR}/out/kernel}"
CONFIG_FRAGMENT="${ROOT_DIR}/configs/kernel/emerald_gki.config"

echo "============================================="
echo "Building GKI Kernel from source for Emerald"
echo "Kernel Source: ${KERNEL_DIR}"
echo "Output Dir:    ${OUT_DIR}"
echo "============================================="

if [ ! -d "${KERNEL_DIR}" ]; then
    echo "Kernel source directory not found at: ${KERNEL_DIR}"
    echo "To fetch Google AOSP Linux 6.12 GKI source, run:"
    echo "  git clone --depth 1 -b android16-6.12 https://android.googlesource.com/kernel/common ${KERNEL_DIR}"
    exit 1
fi

mkdir -p "${OUT_DIR}"

export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export LLVM=1
export LLVM_IAS=1

echo "==> Generating defconfig (gki_defconfig + emerald_gki.config)..."
make -C "${KERNEL_DIR}" O="${OUT_DIR}" gki_defconfig

if [ -f "${CONFIG_FRAGMENT}" ]; then
    echo "==> Merging Emerald fragment config..."
    "${KERNEL_DIR}/scripts/kconfig/merge_config.sh" -m -O "${OUT_DIR}" "${OUT_DIR}/.config" "${CONFIG_FRAGMENT}"
    make -C "${KERNEL_DIR}" O="${OUT_DIR}" olddefconfig
fi

echo "==> Compiling Image and modules..."
make -C "${KERNEL_DIR}" O="${OUT_DIR}" -j"$(nproc)" Image modules

echo "==> Compressing Image.lz4..."
lz4 -f -9 "${OUT_DIR}/arch/arm64/boot/Image" "${OUT_DIR}/Image.lz4"

echo "==> Kernel built successfully!"
ls -lh "${OUT_DIR}/Image.lz4"
