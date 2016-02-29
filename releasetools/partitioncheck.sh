#!/sbin/sh

# Script to check whether or not device is virtually partitioned
# (/data size is ~11GB and /system size is ~2GB)
#
# Usage
#   result 0: device has the appropriate space for virtually partitioned build
#   result 1: device is not virtually partitioned

# Variables
# Size in KiB
DATA_SIZE=$(df -k /data | tail -n 1 | awk '{ print $1 }');
SYSTEM_SIZE=$(df -k /system | tail -n 1 | awk '{ print $1 }');
GB_11=11534336 # 11GB
GB_1_5=1572864 # 1.5GB
GB_2=2066172 # 2GB
# Partitions
DATA_PARTITION=$(df -k /data | tail | grep /dev | awk '{ print $1 }');
SYSTEM_PARTITION=$(df -k /system | tail | grep /dev | awk '{ print $1 }');
VP_DATA_PARTITION="/dev/block/mmcblk0p28"
VP_SYSTEM_PARTITION="/dev/block/mmcblk0p25"

# ui_print by Chainfire
OUTFD=$(\
    /sbin/busybox ps | \
    /sbin/busybox grep -v "grep" | \
    /sbin/busybox grep -o -E "/tmp/updater .*" | \
    /sbin/busybox cut -d " " -f 3\
);

if /sbin/busybox test -e /tmp/update_binary ; then
    OUTFD=$(\
        /sbin/busybox ps | \
        /sbin/busybox grep -v "grep" | \
        /sbin/busybox grep -o -E "update_binary(.*)" | \
        /sbin/busybox cut -d " " -f 3\
    );
fi

ui_print() {
    if [ "${OUTFD}" != "" ]; then
        echo "ui_print ${1} " 1>&"${OUTFD}";
        echo "ui_print " 1>&"${OUTFD}";
    else
        echo "${1}";
    fi
}

# Partition Check
ui_print "Checking partitions..."
if [ "$DATA_PARTITION" != "$VP_DATA_PARTITION" ]; then
  if [ "$SYSTEM_PARTITION" != "$VP_SYSTEM_PARTITION" ]; then
    ui_print "Partition layout invalid for build!"
    ui_print "You are most likely using a non-virtually partitioned recovery"
    ui_print "Make sure you followed the instructions for virtually partitioning your device"
    ui_print "Visit the XDA thread for your device for more information"
    exit 1
  fi
fi

if [ "$DATA_SIZE" -lt "$GB_11" ]; then
  if [ "$SYSTEM_SIZE" -lt "$GB_1_5" ]; then
    ui_print "/data and /system size are too small. Did you repartition?"
    ui_print "Make sure you followed the instructions for virtually partitioning your device"
    ui_print "Visit the XDA thread for your device for more information"
    exit 1
  else
    ui_print "/data size is too small. Did you repartition or flash a custom PIT?"
    ui_print "Make sure to flash back to stock PIT layout, then virtually partition your device"
    ui_print "Visit the XDA thread for your device for more information"
    exit 1
  fi
fi

# Good 2 Go
exit 0
