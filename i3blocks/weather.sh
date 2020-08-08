#!/bin/bash
weather=$(curl -s wttr.in/"$(curl --silent ipinfo.io/loc)"\?format\=2)
if [[ $weather == *"Unknown"* ]]
then
    # First echo updates the full_text i3bar key
    echo "Weather info not available"
    # Second echo updates the short_text i3bar key
    echo "Weather info not available"
    # Third echo updates the color i3bar key
    echo "#b57614" 
else
    # First echo updates the full_text i3bar key
    echo "$weather"
fi
