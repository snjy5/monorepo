#!/bin/bash
/etc/custom_scripts/nvidia-sleep.sh "resume"
# Check whether tty of Xorg to ensure system don't suspend when on tty
if pgrep -x "Xorg" > /dev/null; then
	# monitor dpms is on or off
	dpms_status=$(su - void -c "DISPLAY=:0 xset q | grep 'Monitor is Off'")
	
	# Only suspend if monitor/dpms is off
	if [[ "$dpms_status" == *"Monitor is Off"* ]] && [[ ! -e /tmp/lock ]]; then
		echo "Monitor is off. Suspending the GPU to save power."
		chvt 63
		/etc/custom_scripts/nvidia-sleep.sh "suspend"
	fi
else
	echo "X server is not running. Cannot check DPMS status."
fi
