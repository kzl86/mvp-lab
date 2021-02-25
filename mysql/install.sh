#!/bin/bash

# This script will install and configure the needed services
# Host OS: Ubuntu 18 bionic

# Variables need to be adjusted to infrastructure

# not used
#APACHE_ECS_CLIENT_IP=''

# Needs to be run as root

apt update
install mysql-server -y

mysql_secure_installation

sed -i "s/bind-address.*/bind-address =*/g" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql