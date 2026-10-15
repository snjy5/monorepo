#!/bin/bash
chmod 1777 /tmp
ethtool -s eth0 wol g
/etc/custom_scripts/zram.sh
/etc/custom_scripts/zswap.sh
# sleep HDD after ~9 minutes
#hdparm -S 100 /dev/sda
/etc/custom_scripts/userspace.sh

# I always forget to resume it
btrfs scrub resume / || true
