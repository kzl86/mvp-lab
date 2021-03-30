#!/bin/bash

# This script 
#  - will install and configure the needed services
#  - intended to use as a Jenkins job
# Host OS: Ubuntu 18 bionic

# Jenkins variables:
# MYSQL_ROOT as secret text

# Update system
yum update -y 

# Install required tools
yum install wget -y

# Download MySQL 5.7
wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

# Install MySQL 5.7
rpm -ivh mysql57-community-release-el7-9.noarch.rpm
yum install mysql-server -y 

# Start MySQL service (enabled by default):
systemctl start mysqld

# Headless secure install: (not working)
# Source: https://gist.github.com/vdvm/24754bf1aee6fd85e1aa

# As non root user:
cat <<EOF >> ~/.my.cnf
[client]
user = root
EOF
echo "password = $(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')" >> ~/.my.cnf 

mysql_secure_installation

sed -i "s/bind-address.*/bind-address =*/g" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql