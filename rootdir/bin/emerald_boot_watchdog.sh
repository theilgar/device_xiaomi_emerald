#!/vendor/bin/sh
#
# Copyright (C) 2026 The LineageOS Project
#
# Emerald Boot Watchdog & Diagnostics Service
# Automatically captures diagnostics and falls back to Recovery on boot hang.
#

TAG="EmeraldWatchdog"

log_kmsg() {
    echo "<4>${TAG}: $1" > /dev/kmsg 2>/dev/null
}

log_kmsg "Boot watchdog started. Monitoring boot completion (max 900s)..."

TIMEOUT=900
INTERVAL=5
ELAPSED=0
LAST_HEARTBEAT=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    BOOT_COMPLETED=$(getprop sys.boot_completed)
    if [ "$BOOT_COMPLETED" = "1" ]; then
        log_kmsg "System boot completed successfully in ${ELAPSED}s. Watchdog exiting."
        exit 0
    fi

    # Output a heartbeat every 60 seconds
    if [ $((ELAPSED - LAST_HEARTBEAT)) -ge 60 ]; then
        DEXOPT_ACTIVE="no"
        if pidof dex2oat >/dev/null 2>&1 || pidof dex2oat64 >/dev/null 2>&1; then
            DEXOPT_ACTIVE="yes"
        fi
        log_kmsg "Heartbeat: elapsed=${ELAPSED}s, sys.boot_completed=${BOOT_COMPLETED:-0}, dexopt_active=${DEXOPT_ACTIVE}"
        LAST_HEARTBEAT="$ELAPSED"
    fi

    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
done

# Check if compilation was still running when timeout was reached
if pidof dex2oat >/dev/null 2>&1 || pidof dex2oat64 >/dev/null 2>&1; then
    log_kmsg "WARNING: dexopt was still actively compiling packages when watchdog expired."
fi

log_kmsg "CRITICAL: Boot timeout reached (${TIMEOUT}s)! sys.boot_completed was not set."
log_kmsg "Dumping crash / debug logs and rebooting into Recovery..."

# Capture debug artifacts for the user to analyze in Recovery
mkdir -p /cache/recovery 2>/dev/null
dmesg > /cache/recovery/boot_timeout_dmesg.txt 2>/dev/null
logcat -d > /cache/recovery/boot_timeout_logcat.txt 2>/dev/null
cp -r /data/anr /cache/recovery/anr 2>/dev/null
cp -r /data/tombstones /cache/recovery/tombstones 2>/dev/null
getprop > /cache/recovery/boot_timeout_props.txt 2>/dev/null
sync

# Trigger reboot to recovery via init
setprop sys.powerctl reboot,recovery 2>/dev/null
sleep 4

# Fallback reboot command
reboot recovery 2>/dev/null
sleep 4

# Hard reboot trigger via sysrq if normal reboot fails
echo b > /proc/sysrq-trigger 2>/dev/null
