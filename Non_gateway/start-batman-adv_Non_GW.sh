#!/bin/bash
set -e

echo " [1/6] configure wlan0 to ad-hoc (IBSS) mode"
sudo ip link set wlan0 down
sudo iwconfig wlan0 mode ad-hoc
sudo iwconfig wlan0 essid BatmanNetwork
sudo iwconfig wlan0 channel 1

echo " [2/6] add wlan0 to batman-adv"
sudo modprobe batman-adv
sudo batctl if add wlan0
sudo ip link set wlan0 up
sudo ip link set bat0 up

echo " [3/6] configure bat0 static route"
sudo ip route del default
sudo ip route add default via 192.168.199.1 dev bat0

echo " [4/6] configure ARP parameters"
sysctl -w net.ipv4.neigh.default.base_reachable_time_ms=200
sysctl -w net.ipv4.neigh.default.delay_first_probe_time=0
sysctl -w net.ipv4.neigh.default.gc_thresh1=1
sysctl -w net.ipv4.neigh.default.ucast_solicit=0
sysctl -w net.ipv4.neigh.default.gc_stale_time=1
sysctl -w net.ipv4.neigh.default.gc_interval=1
sysctl -w net.ipv4.neigh.default.retrans_time_ms=200

echo " [5/6] configure batman-adv parameters"
sudo batctl dat 0
sudo batctl gw_mode client 3

echo " [6/6] configuration complete. The current status is："
# wait for wlan0 to be active (at most 10 seconds)
for i in {1..10}; do
    status=$(sudo batctl if | grep wlan0 | awk '{print $2}')
    if [ "$status" == "active" ]; then
        echo " wlan0 is active！"
        break
    else
        echo " wait for wlan0 to be active... ($i/10)"
        sleep 1
    fi
done

sudo batctl if
sudo batctl n
