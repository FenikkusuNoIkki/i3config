#!/bin/bash
memory=$(free -m | awk 'NR==2{printf "%s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }')
echo "$memory"
