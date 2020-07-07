#!/usr/bin/env python
import psutil
from psutil._common import bytes2human
used = psutil.virtual_memory().used
total = psutil.virtual_memory().total
print(" %s / %s" % (bytes2human(used),bytes2human(total)))
