#!/bin/bash

set -e
HOTSPOT="pi-hotspot"

VERSION="0.1.2"

cd "/opt/"

rm -rf "$HOTSPOT"

echo "Downloading Pi Hotspot"
curl -L "https://github.com/jesserockz/$HOTSPOT/archive/v$VERSION.tar.gz" | tar xzf -

mv "$HOTSPOT-$VERSION" "$HOTSPOT"

echo "Updating packages..."
apt-get update
echo "Installing required packages..."
apt-get install hostapd dnsmasq libnl-dev -y

echo "Stopping services"
service hostapd stop
service dnsmasq stop

echo "Removing hostapd and dnsmasq from startup sequence"
update-rc.d hostapd remove
update-rc.d dnsmasq remove

echo "Set config for hostapd in init.d file"
awk '/DAEMON_CONF=/ { print "DAEMON_CONF=/etc/hostapd/hostapd.conf"; next }1' /etc/init.d/hostapd | tee /etc/init.d/hostapd > /dev/null

echo "Setting up wlan0"
awk '/wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf/ { print "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"; next }1' /etc/network/interfaces | tee /etc/network/interfaces > /dev/null

echo "Add cronjob to check for wifi every minute"
crontab -l | { cat; echo "* * * * * /opt/pi-hotspot/ap.sh >> /var/log/hotspot.log 2>&1"; } | crontab -

echo "Done"
echo "Will be first run in `expr 60 - $(date +%S)` seconds"
