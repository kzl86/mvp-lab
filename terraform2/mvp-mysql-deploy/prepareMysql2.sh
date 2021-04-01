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

echo ' *** Read in initial password of mysql *** '
INITIALPASS=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')

echo ' *** Create helper script *** '
cat <<EOF >> /init_mysql.sh
#!/bin/bash
(
  sleep 2
  echo "$1"    # Enter password for user root
  sleep 2
  echo "$2"    # New password
  sleep 2
  echo "$2"    # Re-enter new password
  sleep 2
  echo "y"     # Change the password for root ? (Press y|Y for Yes, any other key for No)
  sleep 2
  echo "$2"    # New password
  sleep 2
  echo "$2"    # Re-enter new password
  sleep 2
  echo "y"     # Do you wish to continue with the password provided? (Press y|Y for Yes, any other key for No)
  sleep 2
  echo "y"     # Remove anonymous users? (Press y|Y for Yes, any other key for No)
  sleep 2
  echo "y"     # Disallow root login remotely? (Press y|Y for Yes, any other key for No)
  sleep 2
  echo "y"     # Remove test database and access to it? (Press y|Y for Yes, any other key for No)
  sleep 2
  echo "y"     # Reload privilege tables now? (Press y|Y for Yes, any other key for No)
  sleep 2
) | ./mysql_secure_installation
EOF

echo ' *** Run mysql_secure_installation *** '
sudo chown +x /init_mysql.sh
sudo /init_mysql.sh $INITIALPASS $1

echo ' *** Enable remote access ???  *** '
sed -i "s/bind-address.*/bind-address =*/g" /etc/my.cnf

echo ' *** Restart service *** '
systemctl restart mysqld