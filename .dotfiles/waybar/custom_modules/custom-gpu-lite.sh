#!/bin/bash

raw_temp=$(cat /sys/class/drm/card0/device/hwmon/hwmon5/temp1_input)
temperature=$(($raw_temp/1000))
deviceinfo=$(glxinfo -B | grep 'Device:' | sed 's/^.*: //')
driverinfo=$(glxinfo -B | grep "OpenGL version")

echo '{"text": "  '$temperature'°C", "class": "custom-gpu", "tooltip": "<b>'$deviceinfo'</b>\n'$driverinfo'"}'