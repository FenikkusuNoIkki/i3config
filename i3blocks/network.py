#!/usr/bin/env python
import psutil
import socket
import subprocess

af_map = {
    socket.AF_INET: 'IPv4',
    socket.AF_INET6: 'IPv6',
    psutil.AF_LINK: 'MAC',
}
infos=""
wifi_iface=0
wifi_ip_found=0
eth_iface=0
eth_ip_found=0
for nic, addrs in psutil.net_if_addrs().items():
    if(nic != 'lo'):
        for addr in addrs:
                if(nic[0] == 'w'):
                    wifi_iface=1
                    if(af_map.get(addr.family, addr.family) == "IPv4"):
                        wifi_ip_found=1
                        ssid = subprocess.Popen(['iwgetid', nic, '--raw'],stdout=subprocess.PIPE).communicate()[0].decode('utf-8').strip()
                        infos += "  [" + str(ssid) + "] " + str(addr.address)
                elif(nic[0] == 'e'):
                    eth_iface=1
                    if(af_map.get(addr.family, addr.family) == "IPv4"):
                        eth_ip_found=1
                        infos += " " + str(addr.address)
if(wifi_iface == 1 and wifi_ip_found == 0):
    infos +="睊 "
if(eth_iface == 1 and eth_ip_found == 0):
    infos +=" "
print(infos)
