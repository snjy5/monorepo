#!/bin/bash
interface=wlan0

while true
do	
	# If wpa connection established
	if ping -c10 google.com 2>&1 >/dev/null; then

		ip=$(ip -4 route get 1 | grep -o 'src.*' | awk '{print $2}')
		ip_custom="${ip%.*}.1"
		ip address add $ip_custom/24 dev $interface
		break
	else # Keep waiting if offline
		sleep 5
	fi
done
