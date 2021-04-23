provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket = "kiss-mvp"
    key    = "mvp-lab-ecs"
    region = "us-east-1"
  }
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

# What is needed, here are some references
# vpc id:    data.terraform_remote_state.network.outputs.mvp-vpc-id
# sn id:     data.terraform_remote_state.network.outputs.mvp-frontendsubnet-id

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allow SSH and OpenVPN inbound traffic"
  vpc_id      = aws_vpc.mvp.id

  ingress {
    description = "SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wordpress inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # shouldn't be this limitid to vpc CIDR? 
  }

  ingress {
    description = "Tomcat inbound"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # shouldn't be this limitid to vpc CIDR?
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "mvp-ecs"
  }
}

