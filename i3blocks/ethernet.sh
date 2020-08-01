#!/bin/bash
ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}'
ip addr show wlp2s0 | awk 'NR==3{printf "%s\n", $2}' | sed 's/\/.*//'
