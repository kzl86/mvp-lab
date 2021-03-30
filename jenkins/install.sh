#!/bin/bash
# https://linuxize.com/post/how-to-install-jenkins-on-centos-7/

sudo yum install java-1.8.0-openjdk-devel -y

curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo yum install jenkins -y

sudo systemctl start jenkins

systemctl status jenkins

sudo systemctl enable jenkins

# No firewall on centos 7 instance
# sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
# sudo firewall-cmd --reload

sleep 10
sudo cat /var/lib/jenkins/secrets/initialAdminPassword