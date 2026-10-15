#!/usr/bin/env bash
### Needs net-tools and iproute2
interface=eth0
gateway=192.168.199.39
ip="${gateway%.*}.1/24"

ip link set $interface down
ip link set $interface up
ip address delete $ip dev $interface
ip address add $ip dev $interface
ip route flush all
ip route add $gateway dev $interface
ip route add default via $gateway
