#!/bin/bash
sysctl -w vm.swappiness=100
swapoff /dev/sda1
echo zstd > /sys/module/zswap/parameters/compressor
echo 10 > /sys/module/zswap/parameters/max_pool_percent
echo z3fold > /sys/module/zswap/parameters/zpool
echo 1 > /sys/module/zswap/parameters/enabled
swapon --priority 1 /dev/sda1
