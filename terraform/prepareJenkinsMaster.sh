#!/bin/bash

# This script will install the packages needed for Jenkins master node

# Due to network unreachable
sleep 60

# Install OpenJDK 8 package:
sudo yum install java-1.8.0-openjdk-devel -y

# Import the GPG key of the Jenkins repository:
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo

# Add the LTS repository to the system:
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install latest Jenkins:
sudo yum install jenkins -y

# Start Jenkins service:
sudo systemctl start jenkins

# Enable Jenkins service:
sudo systemctl enable jenkins

# Install packages which are needed for the pipelines:
sudo yum install git wget unzip -y