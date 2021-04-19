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

variable "aws_access_key" { type = string }
variable "aws_secret_key" { type = string }
variable "subnet-id"      { type = string }
variable "vpc-id"         { type = string } 
variable "nfs-client"     { type = string } 

resource "aws_security_group" "proxy" {
  name        = "proxy"
  description = "Allow SSH for admin"
  vpc_id      = var.vpc-id

  ingress {
    description = "SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NFS 111/tcp"
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = [ var.nfs-client ]
  }

  ingress {
    description = "NFS 111/udp"
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = [ var.nfs-client ]
  }

  ingress {
    description = "NFS 2049/tcp"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [ var.nfs-client ]
  }

  ingress {
    description = "NFS 2049/udp"
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = [ var.nfs-client ]
  }

  ingress {
    description = "HTTP proxy"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "mvp-proxy"
  }
}

resource "aws_instance" "mvp-proxy" {
  ami                         = "ami-00e87074e52e6c9f9"
  instance_type               = "t2.micro"
  key_name                    = "zoltan.kiss_training_terraform"
  subnet_id                   = var.subnet-id
  user_data                   = file("../prepareJenkinsNode.sh")
  vpc_security_group_ids      = [ aws_security_group.proxy.id ]
  associate_public_ip_address = "true"

  tags = {
    Name = "mvp-proxy"
  }
}