provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "kiss-mvp"
    key    = "mvp-lab"
    region = "us-east-1"
  }
}

variable "aws_access_key"     { type = string }
variable "aws_secret_key"     { type = string }
# variable "subnet-id"          { type = string }
# variable "vpc-id"             { type = string }
# variable "bastion-private-ip" { type = string }
variable "mysql-clients-ip"   { type = string }
# variable "jenkins-private-ip" { type = string }

resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "Allow SSH for admin"
  vpc_id      = data.terraform_remote_state.network.outputs.mvp-vpc-id

  ingress {
    description = "SSH inbound from mvp-bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${data.terraform_remote_state.network.outputs.mvp-bastion-private-ip}/32" ]
  }

  ingress {
    description = "SSH inbound from mvp-jenkins"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${data.terraform_remote_state.network.outputs.mvp-jenkins-private-ip}/32" ]
  }

  ingress {
    description = "MYSQL inbound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ var.mysql-clients-ip ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name  = "mvp-mysql"
  }
}

resource "aws_instance" "mvp-mysql" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.micro"
  key_name               = "zoltan.kiss_training_terraform"
  subnet_id              = data.terraform_remote_state.network.outputs.mvp-backendsubnet-id
  user_data              = file("../prepareJenkinsNode.sh")
  vpc_security_group_ids = [ aws_security_group.mysql.id ]

  tags = {
    Name = "mvp-mysql"
  }
}