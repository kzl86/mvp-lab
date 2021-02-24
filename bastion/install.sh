#!/bin/bash

# This script will install and configure the needed services
# Host OS: Ubuntu 18 bionic

# Needs to be run as root

wget https://git.io/vpn -O openvpn-install.sh

chmod +x openvpn-install.sh

bash openvpn-install.sh