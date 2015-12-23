#!/bin/bash
#iw dev wlan0 scan ap-force | grep SSID | cut -f2- -d' '
/opt/pi-hotspot/iw wlan0 scan ap-force | /bin/grep -e SSID -e WPA -e WPS -e RSN | /usr/bin/cut -f2- -d' '
