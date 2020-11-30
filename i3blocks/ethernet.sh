#!/bin/bash
ifnames=$(ip link | awk -F: '$0 !~ "vir|wl|^[^0-9]"{print $2}')
if [ -z "$ifnames" ]
then
    # First echo updates the full_text i3bar key
    echo "No ethernet interface found"
    # Second echo updates the short_text i3bar key
    echo "No ethernet interface found"
    # Third echo updates the color i3bar key
    echo "#af3a03"
    exit 1
fi
while IFS= read -r ifname; do
	ip=$(ip addr show $ifname | awk '$1 ~ /^inet$/ {printf "%s\n", $2}' | sed 's/\/.*//' | awk '$1 !~ /127.0.0.1$/ {printf "%s\n", $1}')
	if [ ! -z $ip ]
	then
		if [ $ifname == "lo" ] || [[ $ifname == *"lo"* ]]
		then
    		lo_ip="$ip"
		elif [[ $ifname == *"tun"* ]]
		then
    		tun_ip="$ip"
		else
			eth_ip="$ip"
		fi
	fi
done <<< "$ifnames"

if [ -z "$eth_ip" ]
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
if [ ! -z $lo_ip ] && [ ! -z $tun_ip ]
then
	echo "$eth_ip [lo:$lo_ip / tun:$tun_ip]"
else
	echo "$eth_ip"
fi
