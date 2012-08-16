#!/sbin/sh

# 0: charge
# 1: direct
# 2: recovery_enter
# 3: recovery_end
# 4: download_end

sleep 3
echo 3 > /dev/block/mmcblk0p12

# Enable USB mass storage
echo 0 > /sys/class/android_usb/android0/enable
echo adb,mass_storage > /sys/class/android_usb/android0/functions
echo 1 > /sys/class/android_usb/android0/enable

