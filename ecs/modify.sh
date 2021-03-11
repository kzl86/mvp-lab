#!/bin/bash

# Copy to docker host. This script should be run as root.

# Read in the database server IP address and password.
read -p 'Enter database IP address: ' inputAddress
read -sp 'Enter database password: ' inputPasswd
read -p 'Enter proxy IP address: ' inputAddress2

# Add IP address and password to the wordpress config file.
docker exec -it wordpress sed -i "s/.*DB_PASSWORD.*/define('DB_PASSWORD', '$inputPasswd');/g" /etc/wordpress/config.php
docker exec -it wordpress sed -i "s/.*DB_HOST.*/define('DB_HOST', '$inputAddress');/g" /etc/wordpress/config.php

# Create replicas from the config file using the IP address(es) of the host machine.
for ip in $(hostname -I); do docker exec -it wordpress /bin/bash -c "cp /etc/wordpress/config.php /etc/wordpress/config-$ip.php"; done

# Create folder on host:
mkdir /media/nfs

# Make static entry in fstab for NFS:
echo "$inputAddress2:/share/uploads /media/nfs  nfs      defaults    0       0" >> /etc/fstab

# Mount NFS.
# Note, that the NFS server has to be mounted before any container start.
mount /media/nfs