#!/bin/bash

# Basic preparation for Jenkins node to be able to run Jenkins agent

yum update
yum -y install java-1.8.0-openjdk
yum -y install git