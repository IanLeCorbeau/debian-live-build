#!/bin/bash

printf '%s\n' "source /etc/network/interfaces.d/*" >> /etc/network/interfaces
printf '%s\n' "Available interfaces:"
echo
find /sys/class/net
echo
printf "Which interface would you like to add (eg: wlp1s0): "
read -r IF
touch /etc/network/interfaces.d/"$IF"
printf '%s\n' "# Wireless Interface
allow-hotplug $IF
iface $IF inet dhcp" > /etc/network/interfaces.d/"$IF"
echo
printf "Your SSID: "
read -r ID
printf '%s\n' "wpa-ssid \"$ID\"" >> /etc/network/interfaces.d/"$IF"
echo
printf "Your wpa key (will not echo): "
read -s PW
printf '%s\n' "wpa-psk \"$PW\"" >> /etc/network/interfaces.d/"$IF"
echo
