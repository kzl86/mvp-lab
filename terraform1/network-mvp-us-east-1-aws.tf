provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "kiss-mvp"
    key    = "mvp-lab"
    region = "us-east-1"
  }
}

resource "aws_vpc" "mvp" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name  = "mvp"
  }
}

resource "aws_subnet" "mvp-frontend" {
  vpc_id     = aws_vpc.mvp.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name  = "mvp-frontend"
  }
}

resource "aws_subnet" "mvp-backend" {
  vpc_id     = aws_vpc.mvp.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name  = "mvp-backend"
  }
}

resource "aws_internet_gateway" "mvp" {
  vpc_id = aws_vpc.mvp.id

  tags = {
    Name  = "mvp"
  }
}

resource "aws_route_table" "mvp-frontend" {
  vpc_id = aws_vpc.mvp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mvp.id
  }

  tags = {
    Name  = "mvp-frontend"
  }
}

resource "aws_route_table_association" "mvp-net" {
  subnet_id      = aws_subnet.mvp-frontend.id
  route_table_id = aws_route_table.mvp-frontend.id
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
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
    description = "OpenVPN inbound"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "mvp-bastion"
  }
}

resource "aws_eip" "nat" {

  tags = {
    Name  = "mvp-nat-eip"
  }
}

resource "aws_nat_gateway" "mvp" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.mvp-frontend.id

  tags = {
    Name  = "mvp-nat-eip"
  }
}

resource "aws_route_table" "mvp-backend" {
  vpc_id = aws_vpc.mvp.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mvp.id
  }

  tags = {
    Name  = "mvp-backend"
  }
}

resource "aws_route_table_association" "mvp-nat" {
  subnet_id      = aws_subnet.mvp-backend.id
  route_table_id = aws_route_table.mvp-backend.id
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow SSH for admin"
  vpc_id      = aws_vpc.mvp.id

  ingress {
    description = "SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP inbound for jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "mvp-jenkins"
  }
}

output "mvp-vpc-id" {
  value = aws_vpc.mvp.id
}

output "mvp-backendsubnet-id" {
  value = aws_subnet.mvp-backend.id
}

output "mvp-frontendsubnet-id" {
  value = aws_subnet.mvp-frontend.id
}