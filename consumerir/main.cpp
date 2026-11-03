/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "ConsumerIr.h"

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

using aidl::android::hardware::ir::ConsumerIr;

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(0);

    auto ir_service = ::ndk::SharedRefBase::make<ConsumerIr>();
    const std::string name = std::string() + ConsumerIr::descriptor + "/default";

    binder_status_t status = AServiceManager_addService(ir_service->asBinder().get(), name.c_str());
    CHECK_EQ(status, STATUS_OK) << "Failed to register ConsumerIr service: " << name;

    LOG(INFO) << "ConsumerIr AIDL service registered successfully: " << name;

    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE; // Should not reach here
}
