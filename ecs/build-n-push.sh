#!/bin/bash

echo 'Build and push wordpress and tomcat docker image to AWS repo.'

read -p 'Enter wordpress repository url: ' wordpressurl
read -p 'Enter tomcat repository url: ' tomcaturl

git clone https://github.com/kzl86/mvp-lab

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(echo $wordpressurl | awk -F "/" '{print $1}')

docker build -t mvp-wordpress mvp-lab/ecs/wordpress

docker tag mvp-wordpress:latest $wordpressurl:latest

docker push $wordpressurl:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(echo $tomcaturl | awk -F "/" '{print $1}')

docker build -t mvp-tomcat mvp-lab/ecs/tomcat

docker tag mvp-tomcat:latest $tomcaturl:latest

docker push $tomcaturl:latest