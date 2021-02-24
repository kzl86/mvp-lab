#!/bin/bash

# This script will install and configure the needed services
# Host OS: CentOS 7

# Variables need to be adjusted to infrastructure

NFS_CLIENT_IP=''
USER=''
APACHE_ECS_IP=''
TOMCAT_ECS_IP=''

# Needs to be run as root

yum install nfs-utils rpcbind -y

systemctl enable nfs-server
systemctl enable rpcbind

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

mkdir -p /share/images
chmod 755 /share 
chown $USER:$USER /share/images

echo "/share/images $NFS_CLIENT_IP(rw,all_squash,insecure,no_subtree_check)" >> /etc/exports
exportfs -r

systemctl restart nfs-server

firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

cat <<EOF >> /etc/ssh/sshd_config
Match User $USER
  ChrootDirectory /share
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
EOF

systemctl restart sshd

#usermod <> -s /bin/false

yum install httpd -y

cat <<EOF >> /etc/httpd/conf.d/reverse.conf
<VirtualHost *:80> 
        ProxyPass "/wp-admin" "http://$APACHE_ECS_IP/" 
        ProxyPassReverse "/wp-admin" "http://$APACHE_ECS_IP/" 
        ProxyPass "/adamcat" "http://$TOMCAT_ECS_IP/" 
        ProxyPassReverse "/adamcat" "http://$TOMCAT_ECS_IP/" 
</Virtualhost>
EOF