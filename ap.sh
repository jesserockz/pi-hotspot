#!/bin/bash
#
# Interface checker
# Checks to see whether interface has an IP address, if it doesn't assume it's down and start hostapd
# Author : SirLagz
# Modified : Jesserockz
#
Interface='wlan0'
HostAPDIP='10.0.0.1'
echo "-----------------------------------"
echo "Checking connectivity of $Interface"
NetworkUp=`/sbin/ifconfig $Interface`
IP=`echo "$NetworkUp" | grep inet | grep -v inet6 | wc -l`

serial=`cat /proc/cpuinfo | tail -c 5`
echo -e "interface=wlan0\ndriver=nl80211\nssid=Zer0-$serial\nhw_mode=g\nchannel=11\nwpa=2\nwpa_passphrase=zer0config\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf

echo -e "interface=$Interface\ndhcp-range=10.0.0.2,10.0.0.50,255.255.255.0,12h\naddress=/#/$HostAPDIP" > /etc/dnsmasq.conf


if [[ $IP -eq 0 ]]; then
  echo "Connection is down"


  hostapd=`pidof hostapd`
  if [[ -z $hostapd ]]; then
    # If there are any more actions required when the interface goes down, add them here
    echo "Attempting to start hostapd"
    /etc/init.d/hostapd start
    echo "Attempting to start dnsmasq"
    /etc/init.d/dnsmasq start
    echo "Setting IP Address for $Interface"
    /sbin/ifconfig $Interface $HostAPDIP netmask 255.255.255.0 up
    echo "Starting python server"
    /usr/bin/python /opt/pi-hotspot/start.py&
  fi
elif [[ $IP -eq 1 && $NetworkUp =~ $HostAPDIP ]]; then
  echo "IP is $HostAPDIP - hostapd is running"
else
  echo "Connection is up"
  hostapd=`pidof hostapd`
  if [[ ! -z $hostapd ]]; then
    echo "Attempting to stop hostapd"
    /etc/init.d/hostapd stop
    echo "Attempting to stop dnsmasq"
    /etc/init.d/dnsmasq stop
    echo "Renewing IP Address for $Interface"
    /sbin/dhclient $Interface
  fi
fi
echo "-----------------------------------"
