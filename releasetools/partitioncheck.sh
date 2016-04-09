#!/sbin/sh

# Script to check whether or not device is virtually partitioned
# (/data size is ~11GB and /system size is ~2GB)
#
# Usage
#   result 0: device has the appropriate space for virtually partitioned build
#   result 1: device is not virtually partitioned

# Variables
# Partitions
DATA_FORMAT=$(mount | grep /data | awk '{ print $5 }');
DATA_PARTITION=$(mount | grep /data | awk '{ print $1 }');
SYSTEM_PARTITION=$(mount | grep /system | awk '{ print $1 }');
VP_DATA_PARTITION="/dev/block/mmcblk0p28"
VP_SYSTEM_PARTITION="/dev/block/mmcblk0p25"
# PIT
STOCK_PIT_MD5="b8997d010456d4f1986db968b28c53ec"
PIT_MD5=$(md5sum /dev/block/mmcblk0p11 | awk '{ print $1 }');

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
    ui_print "You are using a non-virtually partitioned recovery"
    ui_print "Make sure you followed the instructions for virtually partitioning your device"
    ui_print "Visit the XDA thread for your device for more information"
    exit 1
  fi
fi

if [ "$PIT_MD5" != "$STOCK_PIT_MD5" ]; then
  ui_print "Invalid PIT detected!"
  ui_print "You'll need to flash back to stock PIT"
  ui_print "Visit the XDA thread for your device for more information"
  exit 1
fi

if [ "$DATA_FORMAT" == "vfat" ]; then
  ui_print "Invalid format for data!"
  ui_print "Data should be formatted as ext4 or f2fs"
  ui_print "Make sure you followed the instructions for virtually partitioning your device"
  ui_print "Visit the XDA thread for your device for more information"
  exit 1
fi

# Good 2 Go
exit 0
