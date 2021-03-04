#!/bin/bash

# This script will install and configure the needed services
# Host OS: CentOS 7

# Variables need to be adjusted to infrastructure

ECS_IP=''
USER='uploader'

# Needs to be run as root

adduser $USER
mkdir /home/$USER/.ssh/
chown $USER:$USER /home/$USER/.ssh/
cp /home/ec2-user/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys

USER_ID=$(cat /etc/passwd | grep $USER | awk -F: '{print $3}')
USER_GID=$(cat /etc/passwd | grep $USER | awk -F: '{print $4}')

yum install nfs-utils rpcbind -y

systemctl enable nfs-server
systemctl enable rpcbind

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

mkdir -p /share/uploads
chmod 755 /share 
chown $USER:$USER /share/uploads

# have to check what kind of uid /gid will remote has 
echo "/share/uploads $ECS_IP(rw,all_squash,insecure,no_subtree_check,anonuid=$USER_ID,anongid=$USER_GID)" >> /etc/exports
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

# NB The / proxypass is needed to display all of the element
# of the TC page;

cat <<EOF >> /etc/httpd/conf.d/reverse.conf
<VirtualHost *:80> 
        ProxyPass "/wp-admin/" "http://$ECS_IP/blog/" 
        ProxyPassReverse "/wp-admin/" "http://$ECS_IP/blog/" 
        ProxyPass "/adamcat/" "http://$ECS_IP:8080/" 
        ProxyPassReverse "/adamcat/" "http://$ECS_IP:8080/"
        ProxyPass "/" "http://$ECS_IP:8080/" 
        ProxyPassReverse "/" "http://$ECS_IP:8080/"
</Virtualhost>
EOF

systemctl enable httpd
systemctl start httpd

# http://sysadminsjourney.com/content/2010/02/01/apache-modproxy-error-13permission-denied-error-rhel/
# /usr/sbin/setsebool httpd_can_network_connect 1
/usr/sbin/setsebool -P httpd_can_network_connect 1

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload