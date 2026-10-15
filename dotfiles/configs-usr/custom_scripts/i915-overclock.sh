#!/bin/sh
# Overclock intel card
chmod -R a=rwx /sys/class/drm/card0/gt*
for i in /sys/class/drm/card0/gt*
do 
    echo 1050 > "$i" || true
done
