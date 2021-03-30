provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key"     { type = string }
variable "aws_secret_key"     { type = string }
variable "subnet-id"          { type = string }
variable "vpc-id"             { type = string }
variable "bastion-private-ip" { type = string }
variable "mysql-clients-ip"   { type = string }

resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "Allow SSH for admin"
  vpc_id      = var.vpc-id

  ingress {
    description = "SSH inbound only from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.bastion-private-ip ]
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
  subnet_id              = var.subnet-id
  user_data              = file("../prepareJenkinsNode.sh")
  vpc_security_group_ids = [ aws_security_group.mysql.id ]

  tags = {
    Name = "mvp-mysql"
  }
}