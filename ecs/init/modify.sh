#!/bin/bash

# Copy to docker host. This script should be run as root.

# Arguments
# $1 database IP address
# $2 database password
# $3 proxy IP address

WORDPRESS_C_NAME=$(docker ps | grep wordpress | awk '{print $(NF)}')

# Add IP address and password to the wordpress config file.
docker exec -it $WORDPRESS_C_NAME sed -i "s/.*DB_PASSWORD.*/define('DB_PASSWORD', '$2');/g" /etc/wordpress/config.php
docker exec -it $WORDPRESS_C_NAME sed -i "s/.*DB_HOST.*/define('DB_HOST', '$1');/g" /etc/wordpress/config.php

# Create replicas from the config file using the IP address(es) of the host machine.
for ip in $(hostname -I); do docker exec -it $WORDPRESS_C_NAME /bin/bash -c "cp /etc/wordpress/config.php /etc/wordpress/config-$ip.php"; done

# Create folder on host:
mkdir /media/nfs

# Make static entry in fstab for NFS:
echo "$3:/share/uploads /media/nfs  nfs      defaults    0       0" >> /etc/fstab

# Mount NFS.
# Note, that the NFS server has to be mounted before any container start.
mount /media/nfs