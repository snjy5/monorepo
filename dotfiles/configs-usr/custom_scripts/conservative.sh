#!/bin/bash
min_GHz="0.8"
max_GHz="3.4"
min_KHz="$(echo "${min_GHz}"'*1000*1000/1' | bc)"
max_KHz="$(echo "${max_GHz}"'*1000*1000/1' | bc)"

modprobe cpufreq_conservative
for i in /sys/devices/system/cpu/*/cpufreq/scaling_governor; do
echo conservative > "$i"
done

for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
echo "${min_KHz}" > "$i"
done

for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
echo "${max_KHz}" > "$i"
done

for i in /sys/block/*/queue/scheduler; do
echo bfq > "$i" 
done

for i in /sys/devices/system/cpu/cpu*/power/energy_perf_bias; do
# Set 15 to conserve more energy (0 for max performance)
echo 15 > "$i"
done

# suspend certain devices 
powertop --auto-tune
# don't suspend these usb peripherals
for i in /sys/bus/usb/devices/{0..9}-{0..9}/power/control; do
echo 'on' > $i
done
