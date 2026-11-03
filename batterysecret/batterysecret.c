/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Open-source replacement for Xiaomi proprietary batterysecret daemon.
 * Handles USB-PD and BMS fast charge handshake / verification via sysfs.
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define LOG_TAG "batterysecret_oss"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <log/log.h>

static const char * const SYSFS_AUTH_PATHS[] = {
    "/sys/class/Charging_Adapter/pd_adapter/usbpd_verifed",
    "/sys/class/Charging_Adapter/pd_adapter/pd_auth",
    "/sys/class/Charging_Adapter/pd_adapter/verify_process",
    "/sys/class/power_supply/bms/authentic",
    "/sys/class/power_supply/bms/verify_digest",
    "/sys/class/power_supply/bms/device/verify_digest",
    "/sys/class/qcom-battery/verify_slave_flag",
    "/sys/class/qcom-battery/slave_authentic",
};

static void write_sysfs(const char *path, const char *val) {
    int fd = open(path, O_WRONLY);
    if (fd < 0) {
        return;
    }
    ssize_t ret = write(fd, val, strlen(val));
    if (ret < 0) {
        ALOGW("Failed to write %s to %s: %s", val, path, strerror(errno));
    }
    close(fd);
}

static void handle_charge_auth(void) {
    ALOGI("Triggering Xiaomi fast-charge authentication handshake...");
    for (size_t i = 0; i < sizeof(SYSFS_AUTH_PATHS) / sizeof(SYSFS_AUTH_PATHS[0]); ++i) {
        write_sysfs(SYSFS_AUTH_PATHS[i], "1");
    }
}

int main(void) {
    ALOGI("Starting open-source batterysecret daemon");

    // Perform initial verification upon startup
    handle_charge_auth();

    struct sockaddr_nl sa;
    memset(&sa, 0, sizeof(sa));
    sa.nl_family = AF_NETLINK;
    sa.nl_groups = 1; // Listen to kernel multicast groups

    int sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_KOBJECT_UEVENT);
    if (sock < 0) {
        ALOGE("Failed to create uevent socket: %s", strerror(errno));
        return 1;
    }

    if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
        ALOGE("Failed to bind uevent socket: %s", strerror(errno));
        close(sock);
        return 1;
    }

    char buffer[2048];
    while (1) {
        ssize_t len = recv(sock, buffer, sizeof(buffer) - 1, 0);
        if (len > 0) {
            buffer[len] = '\0';
            if (memmem(buffer, len, "SUBSYSTEM=power_supply", 22) != NULL ||
                memmem(buffer, len, "SUBSYSTEM=typec", 15) != NULL ||
                memmem(buffer, len, "SUBSYSTEM=tcpc", 14) != NULL) {
                handle_charge_auth();
            }
        } else if (len < 0 && errno != EINTR) {
            ALOGE("recv error: %s", strerror(errno));
            sleep(1);
        }
    }

    close(sock);
    return 0;
}
