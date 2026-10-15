#!/bin/bash
modprobe cpufreq_userspace
for i in /sys/devices/system/cpu/*/cpufreq/scaling_governor; do
echo userspace > $i
done

for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed; do
echo "3000000" > $i
done
