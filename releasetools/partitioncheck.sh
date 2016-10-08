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
# This is the stock PIT file's MD5. 
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

# Check if the data partition is, in fact, the data partition.
# The only realistic time this will not be true is if the user is 
# on a non-repartitioned recovery.
if [ "$DATA_PARTITION" != "$VP_DATA_PARTITION" -o "$SYSTEM_PARTITION" != "$VP_SYSTEM_PARTITION" ]; then
  ui_print "Your partition layout isn't supported."
  ui_print "This usually means that you are using a non-virtually partitioned recovery, such as one from http://twrp.me/."
  ui_print "In order to take full advantage of this ROM, you must flash the recovery by bryan2894, linked in the thread."
  ui_print "That custom recovery makes it so everything flashes in the right place."
  ui_print "Otherwise, you would be pretty much unable to flash Gapps, and all your apps, downloads, music, etc, all get squeezed into that already-small 2GB data partition."
  ui_print "The whole point of this virtual repartitioning is to make it so you DON'T run out of storage, not run out twice as fast!"
  ui_print "Make sure you followed the instructions for virtually partitioning your device."
  ui_print "Read Post 2 from the XDA thread for your device for more information."
  exit 1
fi

# Compare the MD5 checksums of the PIT partition, /dev/block/mmcblk0p11, with the
# official one. 
# A custom PIT does us no good.
if [ "$PIT_MD5" != "$STOCK_PIT_MD5" ]; then
  ui_print "You have a custom PIT file, which isn't supported."
  ui_print "You'll need to flash back to stock PIT"
  ui_print "With a custom PIT, unlike on non-repartitioned builds, this actually makes your data storage smaller."
  ui_print "The data partition (originally the internal storage), shared with internal storage, becomes smaller, and the increased space in data becomes the read-only system partition."
  ui_print "If you flashed this ROM like this, you will run out of storage."
  ui_print "The easiest way to do this is to restore to an official Samsung build with Odin or Heimdall."
  ui_print "Make sure you followed the instructions for virtually partitioning your device."
  ui_print "Read post 2 from the XDA thread for your device for more information"
  exit 1
fi

# In order for Android to boot, the data partition must be either ext4 or f2fs.
# If the user didn't repartition properly, that means that they are likely on vfat.
if [ "$DATA_FORMAT" != "ext4" -a "$DATA_FORMAT" != "f2fs" ]; then
  ui_print "The data partition is the wrong filesystem format."
  ui_print "Data, your old internal storage partition, should be formatted as ext4 or f2fs."
  ui_print "Android requires it to be one of these formats for permission support and security."
  ui_print "What it is currently formatted as, $DATA_FORMAT, will not work."
  ui_print "Please backup your internal storage, if you haven't already, and format as either of the above."
  ui_print "Make sure you followed the instructions for virtually partitioning your device."
  ui_print "Read post 2 from the XDA thread for your device for more information"
  exit 1
fi

# Good 2 Go
exit 0
