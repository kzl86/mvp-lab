#!/bin/bash
mysql -u root -p$1 << eof
CREATE DATABASE wordpress;
CREATE USER 'wp_admin'@'localhost' IDENTIFIED BY '$2';
CREATE USER 'wp_admin'@'%' IDENTIFIED BY '$2';
GRANT ALL ON wordpress.* TO 'wp_admin'@'localhost';
GRANT ALL ON wordpress.* TO 'wp_admin'@'%';
FLUSH PRIVILEGES;
eof
