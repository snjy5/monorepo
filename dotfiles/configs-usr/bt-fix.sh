#!/bin/bash 
while true; do
    if [[ ! -e /sys/class/bluetooth/hci0 ]]; then
        rmmod -f btusb xhci_plat_hcd 2>/dev/null || true
        modprobe xhci_plat_hcd
        modprobe btusb force_scofix=true enable_autosuspend=false
        sleep 10
    else
        sleep 10
    fi
done
