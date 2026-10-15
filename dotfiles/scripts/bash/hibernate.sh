#!/bin/bash
# Mounting manually only to hibernate
# it's not mounted on boot as it slows system down
#swapon --priority 1 /dev/disk/by-label/SWAP
# Hibernate after hibernating nvidia gpu
/etc/custom_scripts/nvidia-sleep.sh "hibernate" && sleep 2
systemctl hibernate && sleep 2
# Resume nvidia gpu from hibernation (this script still running)
/etc/custom_scripts/resume.sh
