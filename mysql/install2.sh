#!/bin/bash

# This script 
#  - will install and configure the needed services
#  - intended to use as a Jenkins job
# Host OS: Ubuntu 18 bionic

# Jenkins variables:
# MYSQL_ROOT as secret text

apt update
apt install mysql-server -y

mysql_secure_installation

sed -i "s/bind-address.*/bind-address =*/g" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql