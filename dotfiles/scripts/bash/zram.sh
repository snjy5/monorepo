#!/bin/bash
sysctl --write vm.swappiness=100
swapoff /dev/zram0 && rmmod zram
modprobe zram num_devices=1
modprobe zstd
echo zstd > /sys/class/block/zram0/comp_algorithm
echo 2000M > /sys/block/zram0/disksize
# Max internal RAM to use for compression
echo 1000M > /sys/block/zram0/mem_limit
/sbin/mkswap /dev/zram0
swapon --priority 2 /dev/zram0
