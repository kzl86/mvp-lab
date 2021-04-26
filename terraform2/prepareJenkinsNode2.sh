#!/bin/bash

# Basic preparation for Jenkins node to be able to run Jenkins agent

# This script is the initialization for mvp-proxy and mvp-mysql

sudo yum update -y
sudo yum -y install java-1.8.0-openjdk
sudo yum -y install git