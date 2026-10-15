#!/bin/bash
reset -Q
trap 'printf "\033[?25h"; printf "\n"; printf "\r"; reset -Q; exit' INT TERM EXIT QUIT # Unhide cursor
files=(/sys/devices/system/cpu/cpu*/cpufreq/stats/time_in_state)
cpu_count=${#files[@]}

print_table() {
# read frequencies from first CPU
mapfile -t freqs < <(awk '{print $1}' "${files[0]}")

# read columns per CPU
declare -a cpu_data
for idx in "${!files[@]}"; do
    mapfile -t col < <(awk '{print $2}' "${files[$idx]}")
    cpu_data[$idx]="${col[*]}"
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
}

while true; do
    printf "\033[?25l" # Hides cursor
    printf "\033[0;0H" # Move to row 1 column 1
    print_table
    sleep 0.1
done
