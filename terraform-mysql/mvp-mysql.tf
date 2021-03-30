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

resource "aws_key_pair" "my" {
  key_name   = "zoltan.kiss_training_terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClT4n6Dy6Ux4kvhG8wxk7MaEA7wR5QzW0vH+iGkX0huGNOSUyiQIVPD9bokK7yVdy+ynIdqm3qyXFGmybFaU8u4eYumyI7sEPxDbHZmSsUsayHzvKUDSoccaHpDJmtQVBejtT7+jCoE9dlS0VTXVKcw9oqGMAWoOJXFacgHYUDKEFb6JhqEZJmVLT+n7tN5l4tKZZHq2d18s70MDbQcnaZUQu+uCT/gyesTMzDOye6sYq9TqAEf7GsvY3mxI0wYvx4cXB81zSunH6kCHg3J7XBSA9Sf0e7JiAOzpcDUhajRxfxLwWxdxcStKpyIUsV10L/sA0V2Q7rEVpEbAAvx6CFPRjFUUlYlBrasXpPUd2pHg8zkbcO1wfFiIOX4KN8ul6MFCwMGNKHW4ccnPLqXUd6B2cbn3YtyK/ffoVBHz200pGUa3Yo3Q9a85ZiugWfBEm7jbq3ywyidM66JphnlCCo5gzF27XM5Txvk3VgJiDUISDZIOFDF6bgfLJl+0qitEU= terraform"
} 

variable "subnet-id" {
  type    = string
  default = "start123"
}

resource "aws_instance" "mvp-mysql" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my.key_name
  subnet_id              = var.subnet-id

  tags = {
    Name = "mvp-mysql"
  }
}