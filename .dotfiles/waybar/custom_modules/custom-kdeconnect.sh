#
# Shamefully massacred from haideralipunjabi's polybar-kdeconnect 
# (https://github.com/haideralipunjabi/polybar-kdeconnect/)
#

# Color Settings of Icon shown in Waybar
COLOR_DISCONNECTED='#655b53'        # Device Disconnected
COLOR_BATTERY_90='#ebdbb2'          # Battery >= 90
COLOR_BATTERY_80='#a89985'             # Battery >= 80
COLOR_BATTERY_70='#448488'             # Battery >= 70
COLOR_BATTERY_60='#83a597'             # Battery >= 60
COLOR_BATTERY_50='#b16185'             # Battery >= 50
COLOR_BATTERY_LOW='#BF616A'         # Battery <  50

# Icons shown in Polybar
ICON_SMARTPHONE=''
ICON_TABLET=''

devices=""

get_icon () {
    if [ "$2" = "tablet" ]
    then
        icon=$ICON_TABLET
    else
        icon=$ICON_SMARTPHONE
    fi
    case $1 in
    "-1")     ICON="<span foreground=\"$COLOR_DISCONNECTED\">$icon</span>" ;;
    "-2")     ICON="<span foreground=\"$COLOR_NEWDEVICE\">$icon</span>" ;;
    5*)     ICON="<span foreground=\"$COLOR_BATTERY_50\">$icon</span>" ;;
    6*)     ICON="<span foreground=\"$COLOR_BATTERY_60\">$icon</span>" ;;
    7*)     ICON="<span foreground=\"$COLOR_BATTERY_70\">$icon</span>" ;;
    8*)     ICON="<span foreground=\"$COLOR_BATTERY_80\">$icon</span>" ;;
    9*|100) ICON="<span foreground=\"$COLOR_BATTERY_90\">$icon</span>" ;;
    *)      ICON="<span foreground=\"$COLOR_BATTERY_LOW\">$icon</span>" ;;
    esac
    echo $ICON
}

get_status() {
    for device in $(qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices); do
        deviceid=$(echo "$device" | awk -F'["|"]' '{print $2}')
        isreach="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid" org.kde.kdeconnect.device.isReachable)"
        istrust="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid" org.kde.kdeconnect.device.isTrusted)"
        if [ "$isreach" = "true" ] && [ "$istrust" = "true" ]
        then
            battery="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid/battery" org.kde.kdeconnect.device.battery.charge)%"
            icon=$(get_icon "$battery" "$devicetype")
            devices+="$battery $icon"
        elif [ "$isreach" = "false" ] && [ "$istrust" = "true" ]
        then
            devices+="$(get_icon -1 "$devicetype")"
        fi
    done

    echo $devices
}

send_ring() {
    for device in $(qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices); do
        deviceid=$(echo "$device" | awk -F'["|"]' '{print $2}')
        isreach="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid" org.kde.kdeconnect.device.isReachable)"
        istrust="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid" org.kde.kdeconnect.device.isTrusted)"
        if [ "$isreach" = "true" ] && [ "$istrust" = "true" ]
        then
            $(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$deviceid/findmyphone" org.kde.kdeconnect.device.findmyphone.ring)
        fi
    done

    echo $devices
}


option="${1}"
    case "${option}" in
        ring) send_ring
            ;;
        battery) get_status
            ;;
        *) echo "Use with ./custom-kdeconnect.sh battery or ring"
            ;;
    esac

exit 0