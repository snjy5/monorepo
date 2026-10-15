#!/bin/sh
COLUMNS="$(tput cols)"
tr -c '[:digit:]' ' ' < /dev/random |
	dd cbs="$COLUMNS" bs=1 conv=unblock 2>/dev/null |
	awk '{if (system("sleep .01 && exit 2") != 2) exit; print}' |
	GREP_COLORS="mt=1;32" grep --color "[^ ]"
