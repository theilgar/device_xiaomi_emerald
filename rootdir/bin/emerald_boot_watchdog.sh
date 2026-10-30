#!/vendor/bin/sh
#
# Copyright (C) 2026 The LineageOS Project
#
# Emerald 5-minute Boot Watchdog to Recovery
# Automatically falls back to Recovery if Android fails to boot within 5 minutes.
#

TAG="EmeraldWatchdog"

log_kmsg() {
    echo "<4>${TAG}: $1" > /dev/kmsg 2>/dev/null
}

log_kmsg "Boot watchdog started. Waiting up to 900 seconds for boot completion..."

TIMEOUT=900
INTERVAL=5
ELAPSED=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    BOOT_COMPLETED=$(getprop sys.boot_completed)
    if [ "$BOOT_COMPLETED" = "1" ]; then
        log_kmsg "System boot completed successfully in ${ELAPSED}s. Watchdog exiting cleanly."
        exit 0
    fi
    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
done

# If we get here, 5 minutes elapsed and system is still not booted!
log_kmsg "CRITICAL: Boot timeout reached (${TIMEOUT}s)! sys.boot_completed was not set."
log_kmsg "Dumping crash / debug logs and rebooting into Recovery..."

# Capture debug artifacts for the user to analyze in Recovery
mkdir -p /cache/recovery 2>/dev/null
dmesg > /cache/recovery/boot_timeout_dmesg.txt 2>/dev/null
logcat -d > /cache/recovery/boot_timeout_logcat.txt 2>/dev/null
sync

# Trigger reboot to recovery via init
setprop sys.powerctl reboot,recovery 2>/dev/null
sleep 4

# Fallback reboot command
reboot recovery 2>/dev/null
sleep 4

# Hard reboot trigger via sysrq if normal reboot fails
echo b > /proc/sysrq-trigger 2>/dev/null
