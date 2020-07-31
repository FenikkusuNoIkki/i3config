#!/bin/bash
echo $(sensors | grep -F 'Core' | awk '{print $3}' | tr -s '\n' ' ' | sed 's/+//g')
