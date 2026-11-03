/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <aidl/android/hardware/ir/BnConsumerIr.h>
#include <aidl/android/hardware/ir/ConsumerIrFreqRange.h>

namespace aidl::android::hardware::ir {

class ConsumerIr : public BnConsumerIr {
  public:
    ConsumerIr() = default;
    ~ConsumerIr() override = default;

    ::ndk::ScopedAStatus getCarrierFreqs(
            std::vector<ConsumerIrFreqRange>* _aidl_return) override;
    ::ndk::ScopedAStatus transmit(
            int32_t in_carrierFreqHz,
            const std::vector<int32_t>& in_pattern) override;
};

}  // namespace aidl::android::hardware::ir
