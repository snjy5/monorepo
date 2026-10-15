#!/bin/bash
test -e /tmp/lock && exit

# Ensure system don't hibernate on tty
if pgrep -x "Xorg" > /dev/null; then

# Check DPMS status
dpms_status=$(su - void -c \
"DISPLAY=:0 xset q |\
grep 'Monitor is Off'")

# Only hibernate if monitor/dpms is off
if [[ "$dpms_status" == *"Monitor is Off"* ]] && ! pgrep mpv
then
echo "Monitor is off. Hibernating the \
system to save power."
/etc/custom_scripts/hibernate.sh
else
echo "Monitor is on or lock file exists or crucial app open..\
No action taken."
fi
else
echo "X server is not running. Cannot check DPMS status."
fi
