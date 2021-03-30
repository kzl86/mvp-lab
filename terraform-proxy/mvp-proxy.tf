provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {
  type    = string
}

variable "aws_secret_key" {
  type    = string
}

variable "subnet-id" {
  type    = string
  default = "start123"
}

resource "aws_instance" "mvp-proxy" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.micro"
  key_name               = "zoltan.kiss_training_terraform"
  subnet_id              = var.subnet-id

  tags = {
    Name = "mvp-proxy"
  }
}