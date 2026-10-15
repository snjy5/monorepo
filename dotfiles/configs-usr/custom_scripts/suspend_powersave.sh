#!/bin/bash
# Suspend system to save power after monitor is off

# 1m delay to give enough time for user to turn back monitor on inactivity
sleep 60

# Ensure system don't suspend on tty
if pgrep -x "Xorg" > /dev/null; then
	# Check DPMS status
	dpms_status=$(su - void -c "DISPLAY=:0 xset q | grep 'Monitor is Off'")
	
	# Only suspend if monitor/dpms is off
	if [[ "$dpms_status" == *"Monitor is Off"* ]] && [[ ! -e /tmp/lock ]]; then
		echo "Monitor is off. suspending the system to save power."
		/etc/custom_scripts/suspend.sh
	else
		echo "Monitor is on or lock file exists.. No action taken."
	fi
else
	echo "X server is not running. Cannot check DPMS status."
fi
