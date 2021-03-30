#!/bin/bash

# This script will install and configure the needed services
# Host OS: Centos7

# Needs to be run as root

yum install wget -y

wget https://git.io/vpn -O openvpn-install.sh

chmod +x openvpn-install.sh

bash openvpn-install.sh

mv /root/*.ovpn /home/centos/

chown centos:centos /home/centos/*.ovpn