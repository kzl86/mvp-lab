#!/bin/bash

# This script will install and configure the needed services
# Host OS: Ubuntu 18 bionic

# Variables need to be adjusted to infrastructure

##############################NFS_CLIENT_IP=''

# Needs to be run as root

apt update
install mysql-server -y

mysql_secure_installation

sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address            =*

sudo systemctl restart mysql

Creating user:
    sudo mysql -u root -p
    CREATE USER 'kzl3'@'<ip address>' IDENTIFIED BY 'mementomori3';
    GRANT ALL PRIVILEGES ON *.* TO 'kzl3'@'<ip address>' WITH GRANT OPTION;
    flush privileges

Connecting remote:
    GRANT ALL PRIVILEGES ON *.* TO 'kzl'@'192.168.88.214' WITH GRANT OPTION
    flush privileges
    mysql -u kzl -h 192.168.88.70