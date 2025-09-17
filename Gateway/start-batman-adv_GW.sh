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
sudo ifconfig bat0 192.168.199.1/24

echo " [3/6] configure eth1 a static IP"
sudo ip addr flush dev eth1
sudo ip addr add 192.168.0.2/24 dev eth1
sudo ip route add default via 192.168.0.1 dev eth1
echo "nameserver 192.168.0.1" | sudo tee /etc/resolv.conf > /dev/null

echo " [4/6] configure NAT and forwarding rules"
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -A FORWARD -i eth1 -o bat0 -j ACCEPT
sudo iptables -A FORWARD -i bat0 -o eth1 -j ACCEPT

echo " [5/6] configure batman-adv parameters"
sudo batctl dat 0
sudo batctl gw_mode server

echo " [6/6] Configuration complete. The current status: "
# wait wlan0 to be active (10 seconds at most)
for i in {1..10}; do
    status=$(sudo batctl if | grep wlan0 | awk '{print $2}')
    if [ "$status" == "active" ]; then
        echo " wlan0 interface is active！"
        break
    else
        echo " wait for wlan0 to be activated... ($i/10)"
        sleep 1
    fi
done

sudo batctl if
sudo batctl n
