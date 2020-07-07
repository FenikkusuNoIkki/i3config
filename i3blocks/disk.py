#!/usr/bin/env python
import sys
import psutil
from psutil._common import bytes2human
infos=" "
for arg in sys.argv[1:]:
    infos += "[" + arg + "] "
    usage = psutil.disk_usage(arg)
    infos += bytes2human(usage.free) + " "
print(infos)
