#!/bin/bash

# Basic preparation for Jenkins node to be able to run Jenkins agent
yum update -y
yum -y install java-1.8.0-openjdk
yum -y install git

# Install required tools
yum install wget -y

# Download MySQL 5.7
wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

# Install MySQL 5.7
rpm -ivh mysql57-community-release-el7-9.noarch.rpm
yum install mysql-server -y 

# Start MySQL service (enabled by default):
systemctl start mysqld

# Install expect 
yum install expect -y

# Read in initial password of mysql
INITIALPASS=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')

# Call expect script with parameters
secureDb $INITIALPASS $JENKINS_NEWPASS

# Enable remote access
sed -i "s/bind-address.*/bind-address =*/g" /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart service
systemctl restart mysql