#!/bin/bash

# Basic preparation for ecs node 

# This script is the initialization for ecs node

echo ECS_CLUSTER=mvp >> /etc/ecs/ecs.config

yum update
yum -y install java-1.8.0-openjdk
yum -y install git

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html
#echo ' *** Disable the docker Amazon Linux extra repository. *** '
#sudo amazon-linux-extras disable docker

#echo ' *** Install and enable the ecs Amazon Linux extra repository. *** '
#sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs

#echo ' *** verify that the agent is running and see some information about your new container instance *** '
#curl -s http://localhost:51678/v1/metadata | python -mjson.tool