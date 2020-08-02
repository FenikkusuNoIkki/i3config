#!/bin/bash
ifname=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')
if [ -z "$ifname" ]
then
    # First echo updates the full_text i3bar key
    echo "No ethernet interface found"
    # Second echo updates the short_text i3bar key
    echo "No ethernet interface found"
    # Third echo updates the color i3bar key
    echo "#af3a03"
    exit 1
fi
ip=$(ip addr show $ifname | awk '$1 ~ /^inet$/ {printf "%s\n", $2}' | sed 's/\/.*//')
if [ -z "$ip" ]
then
    # First echo updates the full_text i3bar key
    echo "-"
    # Second echo updates the short_text i3bar key
    echo "-"
    # Third echo updates the color i3bar key
    echo "#af3a03"
    exit 1
fi
ping=$(ping -c3 8.8.8.8 | awk '/transmitted/ {print $6}' | tr -d '%')
if [ "$ping" -eq 100 ]
then
    # First echo updates the full_text i3bar key
    echo "Connection lost"
    # Second echo updates the short_text i3bar key
    echo "Connection lost"
    # Third echo updates the color i3bar key
    echo "#af3a03"
    exit 1
elif [ "$ping" -gt 0 ]
then
    # First echo updates the full_text i3bar key
    echo "Unstable connection"
    # Second echo updates the short_text i3bar key
    echo "Unstable connection"
    # Third echo updates the color i3bar key
    echo "#b57614"
    exit 1
fi
echo "$ip"
