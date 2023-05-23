#!/usr/bin/env bash
#IP is your ssh host ip , IFACEIP is the default interface ip addr
#you can obtain IFACEIP via "ip a" or any other method
#in this example , default ip is 192.168.1.1 on interface eth0
IP="123.456.789.000"
IFACEIP="192.168.1.1"
USER=$(whoami)
function handler(){
     ip link set dev tun0 down
     ip link delete tun0
     ip route delete $IP via $IFACEIP metric 5
     ip route add default via $IFACEIP 
}

# Assign the handler function to the SIGINT signal
trap handler SIGINT
 ip tuntap add dev tun0 mode tun user $USER
 ip addr replace 10.0.0.1/24 dev tun0
 
 ip link set dev tun0 up
 ip route add $IP via $IFACEIP metric 5
 route add default gw 10.0.0.2 tun0
 badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:1337 --udpgw-remote-server-addr 127.0.0.1:7200 --loglevel 0 ## delete this line in case no need for UDP packets tunneling, or badvpn-udpgw is not installed on remote server
### in case of non-systemd distro , you should use "route add default gw 10.0.0.2 tun0"
##in case of systemd you can use "ip route add default via 10.0.0.2 tun0"
