#!/usr/bin/env bash

current_source=$(pacmd list-sources | sed -n '/* index/,/active/p')
source_desc=$(echo "$current_source" | awk '/device.description =/{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
echo "$source_desc"
active_port=$(echo "$current_source" | awk '/active port:/{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/<//g' | sed 's/>//')
echo "$active_port"

