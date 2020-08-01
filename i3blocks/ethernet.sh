#!/bin/bash
ifname=$(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}')
ip=$(ip addr show $ifname | awk '$1 ~ /^inet$/ {printf "%s\n", $2}' | sed 's/\/.*//')
echo "$ip"
