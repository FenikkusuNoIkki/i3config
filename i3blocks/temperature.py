#!/usr/bin/env python
import psutil
temps=psutil.sensors_temperatures()
names=set(list(temps.keys()))
temp=""
package=""
package_label_found=False
for name in names:
    # Temperatures.
    if name in temps:
        package_label_found = False
        for entry in temps[name]:
            if "Package" in entry.label:
                if package_label_found is not True: 
                    package = entry.label
                    package_label_found = True
                else:
                    # Somtimes have the information twice
                    if entry.label == package:
                        break
            if "Core" in entry.label:
                temp+=("%s°C " % entry.current)
print(" " + temp)
