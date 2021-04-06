#!/bin/bash

echo ' *** Install required tools  *** '
yum install wget -y

echo ' *** Download MySQL 5.7  *** '
wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

echo ' *** Install MySQL 5.7  *** '
rpm -ivh mysql57-community-release-el7-9.noarch.rpm
yum install mysql-server -y 

echo ' *** Start MySQL service (enabled by default):  *** '
systemctl start mysqld
systemctl status mysqld

echo ' *** Install expect *** '
yum install expect -y

echo ' *** Read in initial password of mysql *** '
INITIALPASS=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')
echo $INITIALPASS

echo ' *** Create helper script *** '
cat <<EOF > /init_mysql.exp
#!/usr/bin/expect --

set oldpass [lindex \$argv 0]
set newpass [lindex \$argv 1]

spawn /bin/mysql_secure_installation

expect "Enter password for user root:"
send "\$oldpass\r"

expect "New password:"
send "\$newpass\r"

expect "Re-enter new password:"
send "\$newpass\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "New password:"
send "\$newpass\r"

expect "Re-enter new password:"
send "\$newpass\r"

expect "Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

puts "Ended expect script."

EOF
cat /init_mysql.exp

echo ' *** Run mysql_secure_installation *** '
sudo chmod +x /init_mysql.exp
sudo /init_mysql.sh $INITIALPASS $1

echo ' *** Enable remote access ???  *** '
sed -i "s/bind-address.*/bind-address =*/g" /etc/my.cnf

echo ' *** Restart service *** '
systemctl restart mysqld

# TBD: wordpress database creation, etc
# see mysql/readme for details