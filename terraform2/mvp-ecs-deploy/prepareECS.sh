#!/bin/bash

# Basic preparation for ecs node 

# This script is the initialization for ecs node

echo ECS_CLUSTER=mvp >> /etc/ecs/ecs.config

yum update
yum -y install java-1.8.0-openjdk
yum -y install git