#!/usr/bin/env bash
# Connect bluetooth
bluetoothctl power on
bluetoothctl agent on
bluetoothctl trust 90:7A:58:CC:11:85
bluetoothctl disconnect 90:7A:58:CC:11:85
bluetoothctl connect 90:7A:58:CC:11:85
