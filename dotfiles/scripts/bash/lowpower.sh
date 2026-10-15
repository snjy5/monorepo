#!/bin/sh
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo powersave > $i; done
for i in /sys/devices/system/cpu/cpu*/power/energy_perf_bias; do echo 1 > $i; done
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do echo 200 > $i; done
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do echo 200 > $i; done
chmod -R 666 /sys/class/drm/card0/gt*
for i in /sys/class/drm/card0/gt*; do echo 100 > $i; done
