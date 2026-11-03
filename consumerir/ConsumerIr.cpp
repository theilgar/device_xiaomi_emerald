/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "ConsumerIr.h"

#include <android-base/logging.h>
#include <fcntl.h>
#include <linux/lirc.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <vector>

namespace aidl::android::hardware::ir {

static const char* kLircDevNodes[] = {
    "/dev/lirc0",
    "/dev/irtx",
};

::ndk::ScopedAStatus ConsumerIr::getCarrierFreqs(
        std::vector<ConsumerIrFreqRange>* _aidl_return) {
    // Standard Consumer Infrared frequency range (30 kHz to 60 kHz)
    _aidl_return->clear();
    _aidl_return->push_back({.minHz = 30000, .maxHz = 60000});
    return ::ndk::ScopedAStatus::ok();
}

::ndk::ScopedAStatus ConsumerIr::transmit(
        int32_t in_carrierFreqHz,
        const std::vector<int32_t>& in_pattern) {
    if (in_carrierFreqHz <= 0) {
        LOG(ERROR) << "Invalid carrier frequency: " << in_carrierFreqHz;
        return ::ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    if (in_pattern.empty()) {
        LOG(ERROR) << "Empty pattern requested";
        return ::ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    int fd = -1;
    for (const char* path : kLircDevNodes) {
        fd = open(path, O_RDWR);
        if (fd >= 0) {
            break;
        }
    }

    if (fd < 0) {
        LOG(ERROR) << "Failed to open IR device: " << strerror(errno);
        return ::ndk::ScopedAStatus::fromServiceSpecificError(-errno);
    }

    // Set carrier frequency
    unsigned int freq = static_cast<unsigned int>(in_carrierFreqHz);
    if (ioctl(fd, LIRC_SET_SEND_CARRIER, &freq) < 0) {
        LOG(ERROR) << "Failed to set LIRC carrier frequency " << in_carrierFreqHz
                   << ": " << strerror(errno);
        close(fd);
        return ::ndk::ScopedAStatus::fromServiceSpecificError(-errno);
    }

    // Set 50% duty cycle (recommended for consumer IR transmission)
    unsigned int duty = 50;
    ioctl(fd, LIRC_SET_SEND_DUTY_CYCLE, &duty);

    // Convert pattern durations to microseconds (unsigned int array expected by LIRC)
    std::vector<unsigned int> durations(in_pattern.begin(), in_pattern.end());
    size_t total_bytes = durations.size() * sizeof(unsigned int);

    ssize_t written = write(fd, durations.data(), total_bytes);
    if (written < 0 || static_cast<size_t>(written) != total_bytes) {
        LOG(ERROR) << "Failed to write IR pulse train to driver: " << strerror(errno);
        close(fd);
        return ::ndk::ScopedAStatus::fromServiceSpecificError(-errno);
    }

    close(fd);
    return ::ndk::ScopedAStatus::ok();
}

}  // namespace aidl::android::hardware::ir
