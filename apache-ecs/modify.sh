#!/bin/bash

# Copy to docker host.

read -p 'Enter database IP address: ' inputAddress
read -sp 'Enter database password: ' inputPasswd

docker exec -it wordpress sed -i "s/.*DB_PASSWORD.*/define('DB_PASSWORD', '$inputPasswd');/g" /etc/wordpress/config.php
docker exec -it wordpress sed -i "s/.*DB_HOST.*/define('DB_HOST', '$inputAddress');/g" /etc/wordpress/config.php

for ip in $(hostname -I); do docker exec -it wordpress /bin/bash -c "cp /etc/wordpress/config.php /etc/wordpress/config-$ip.php"; done
