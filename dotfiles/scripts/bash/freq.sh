#!/bin/bash
files=(/sys/devices/system/cpu/cpu*/cpufreq/stats/time_in_state)
#files=(/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)
cpu_count=${#files[@]}

# read frequencies from first CPU
mapfile -t freqs < <(awk '{print $1}' "${files[0]}")

# read columns per CPU
declare -a cpu_data
for i in "${!files[@]}"; do
    mapfile -t col < <(awk '{print $2}' "${files[$i]}")
    cpu_data[$i]="${col[*]}"
done

# column width (adjust if needed)
W=10

# header
printf "%-${W}s" "freq"
for ((c=0; c<cpu_count; c++)); do
    printf "%-${W}s" "CPU$c"
done
printf "\n"

# rows
for ((i=0; i<${#freqs[@]}; i++)); do
    printf "%-${W}s" "${freqs[$i]}"

    for ((c=0; c<cpu_count; c++)); do
        arr=(${cpu_data[$c]})
        printf "%-${W}s" "${arr[$i]}"
    done

    printf "\n"
done


echo
echo "GPU"
cat /sys/class/drm/card0/gt_cur_freq_mhz | xargs printf "%s\n"
cat /sys/class/drm/card0/gt_act_freq_mhz | xargs printf "%s\n" 
cat /sys/class/drm/card0/gt/gt0/rps_cur_freq_mhz | xargs printf "%s\n"
