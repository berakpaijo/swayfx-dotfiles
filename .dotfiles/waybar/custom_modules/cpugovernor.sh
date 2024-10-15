#!/bin/bash

GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ $GOVERNOR = performance ]; then
	echo '{"text": "perf", "alt": "perf", "class": "performance", "tooltip": "<b>Governor</b> Performance"}'
	if [[ $1 = switch ]]; then
		sudo cpupower frequency-set -g ondemand;pkill -RTMIN+8 waybar;
	fi
	#echo ''
elif [ $GOVERNOR = ondemand ]; then
	echo '{"text": "ondemand", "alt": "ondemand", "class": "ondemand", "tooltip": "<b>Governor</b> On Demand"}'
	if [[ $1 = switch ]]; then
		sudo cpupower frequency-set -g performance;pkill -RTMIN+8 waybar;
	fi
fi