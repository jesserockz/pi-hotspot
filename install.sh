#!/bin/bash

set -e

echo "Updating packages..."
apt-get update
apt-get upgrade -y
echo "Installing required packages..."
apt-get install hostapd dnsmasq libnl-dev -y

echo "Removing hostapd and dnsmasq from startup sequence"
update-rc.d hostapd remove
update-rc.d dnsmasq remove

echo "Set config for hostapd in init.d file"
awk '/DAEMON_CONF=/ { print "DAEMON_CONF=/etc/hostapd/hostapd.conf"; next }1' /etc/init.d/hostapd | tee /etc/init.d/hosted

echo "Set wlan0 to auto instead of allow-hotplug"
awk '/allow-hotplug wlan0/ { print "auto wlan0"; next }1' /etc/network/interfaces | tee /etc/network/interfaces



echo "Add cronjob to check for wifi every minute"
crontab -l | { cat; echo "* * * * * /opt/pi-hotspot/ap.sh >> /var/log/hotspot.log 2>&1"; } | crontab -

echo "Done"
echo "Will be first run in `expr 60 - $(date +%S)` seconds"


auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf