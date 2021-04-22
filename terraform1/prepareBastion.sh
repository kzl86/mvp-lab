#!/bin/bash

echo ' *** Prepare the bastion host to serve as a Jenkins agent *** '
# yum update -y
yum -y install java-1.8.0-openjdk
yum -y install git 

echo ' *** Install tools ***'
yum -y install wget 

echo ' *** Create helper scripts *** '
cat <<EOF >> /init.sh
#!/bin/bash
(
 sleep 2
 echo ""
 sleep 2
 echo ""
 sleep 2
 echo ""
 sleep 2
 echo ""
 sleep 2
 echo "mvp-1"
) | ./openvpn-install.sh
EOF

cat <<EOF >> /mvp2.sh
#!/bin/bash
(
 sleep 2
 echo "1"
 sleep 2
 echo "mvp-2"
 sleep 2
) | ./openvpn-install.sh
EOF

cat <<EOF >> /mvp3.sh
#!/bin/bash
(
 sleep 2
 echo "1"
 sleep 2
 echo "mvp-3"
 sleep 2
) | ./openvpn-install.sh
EOF


echo ' *** Download openvpn-install.sh *** '
wget https://git.io/vpn -O openvpn-install.sh
chmod +x /openvpn-install.sh

echo ' *** Start initialization and create mvp-1,2,3 ***'
chmod +x /init.sh && sudo ./init.sh
chmod +x /mvp2.sh && sudo ./mvp2.sh
chmod +x /mvp3.sh && sudo ./mvp3.sh

# Move client configuration to be easily accessible
mv /root/*.ovpn /home/centos/
chown centos:centos /home/centos/*.ovpn