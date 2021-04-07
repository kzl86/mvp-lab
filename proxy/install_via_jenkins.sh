#!/bin/bash

# This script will install and configure the needed services.
# Needs to be run as root.
# Host OS: CentOS 7.

# Variables need to be adjusted to infrastructure.

# IP address of the ECS / docker host:
ECS_IP=$1
# Username which used for sftp connections:
USER=$2

# Add user to the system, use authorized keys of the existing ec2-user.
adduser $USER
mkdir /home/$USER/.ssh/
chown $USER:$USER /home/$USER/.ssh/
cp /home/ec2-user/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys

# Copy the user and the group ids to separate variables.
USER_ID=$(cat /etc/passwd | grep $USER | awk -F: '{print $3}')
USER_GID=$(cat /etc/passwd | grep $USER | awk -F: '{print $4}')

# Creating the shared folder, set permissions.
mkdir -p /share/uploads
chmod 755 /share 
chown $USER:$USER /share/uploads

# Chroot the sftp user, restart service to take effect. Note that the command usermod <> -s /bin/false not needed.
cat <<EOF >> /etc/ssh/sshd_config
Match User $USER
  ChrootDirectory /share
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
EOF
systemctl restart sshd

# Installing NFS server, enabling and starting services.
yum install nfs-utils rpcbind -y

systemctl enable nfs-server
systemctl enable rpcbind

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

# Register the shared folder to the NFS exports file. This share will trust only one IP address,
# the anonim user connecting will have the user and group id as the sftp user.
# Possible improvement TBD: instead of IP address, refer to DNS name.
echo "/share/uploads $ECS_IP(rw,all_squash,insecure,no_subtree_check,anonuid=$USER_ID,anongid=$USER_GID)" >> /etc/exports
exportfs -r

# Add NFS rules to firewall.
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

# Installing Apache http server.
yum install httpd -y

# Configure reverse proxy, enable and start service. 
# Note, that the "/"" proxypass is needed to display all of the tomcat container element.
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

# SELinux enable httpd processes to initiate outbound connection.
# See http://sysadminsjourney.com/content/2010/02/01/apache-modproxy-error-13permission-denied-error-rhel/
# For temporary enablement: /usr/sbin/setsebool httpd_can_network_connect 1
# For permanent enablement:
/usr/sbin/setsebool -P httpd_can_network_connect 1

# Add firewall rule to enable incoming 80/tcp and reload.
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload

# Install fail2ban:
yum install fail2ban -y

# Create configuration, ssh clients will be banned for 24 hour after 3 unsuccessfull attempt.
cat <<EOF >> /etc/fail2ban/jail.local
[DEFAULT]
# Ban IP/hosts for 24 hour ( 24h*3600s = 86400s):
bantime = 86400

# An ip address/host is banned if it has generated "maxretry" during the last "findtime" seconds.
findtime = 600
maxretry = 3

# "ignoreip" can be a list of IP addresses, CIDR masks or DNS hosts. Fail2ban
# will not ban a host which matches an address in this list. Several addresses
# can be defined using space (and/or comma) separator. For example, add your
# static IP address that you always use for login such as 103.1.2.3
#ignoreip = 127.0.0.1/8 ::1 103.1.2.3

# Call iptables to ban IP address
banaction = iptables-multiport

# Enable sshd protection
[sshd]
enabled = true
EOF

# Enable and start fail2ban service:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban
