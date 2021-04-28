#!/bin/bash

# Basic preparation for ecs node 

# This script is the initialization for ecs node

echo ' *** Prepare node as a jenkins slave *** '
yum update
yum -y install java-1.8.0-openjdk
yum -y install git

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html
echo ' *** Install the ecs-init package. For more information about ecs-init, see the source code on GitHub. *** '
sudo amazon-linux-extras install ecs # this was not working: sudo yum install -y ecs-init (not found)

echo ' *** Start the Docker daemon. *** '
sudo service docker start

echo ' *** Start the ecs-init upstart job. *** '
# this was not working: sudo start ecs
sudo systemctl enable ecs
sudo systemctl start ecs

echo ' *** Add cluster name to ecs.config *** '
echo ECS_CLUSTER=mvp >> /etc/ecs/ecs.config


# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-install.html
#echo ' *** Disable the docker Amazon Linux extra repository. *** '
#sudo amazon-linux-extras disable docker

#echo ' *** Install and enable the ecs Amazon Linux extra repository. *** '
#sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs

#echo ' *** verify that the agent is running and see some information about your new container instance *** '
#curl -s http://localhost:51678/v1/metadata | python -mjson.tool