#!/bin/bash
# Hibernate after suspending nvidia gpu
/etc/custom_scripts/nvidia-sleep.sh "suspend" && sleep 2
echo 'mem' > /sys/power/state && sleep 2
#systemctl suspend
# Resume nvidia gpu from suspend
/etc/custom_scripts/nvidia-sleep.sh "resume"
