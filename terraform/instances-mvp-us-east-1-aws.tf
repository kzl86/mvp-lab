resource "aws_key_pair" "my" {
  key_name   = "zoltan.kiss_training_terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClT4n6Dy6Ux4kvhG8wxk7MaEA7wR5QzW0vH+iGkX0huGNOSUyiQIVPD9bokK7yVdy+ynIdqm3qyXFGmybFaU8u4eYumyI7sEPxDbHZmSsUsayHzvKUDSoccaHpDJmtQVBejtT7+jCoE9dlS0VTXVKcw9oqGMAWoOJXFacgHYUDKEFb6JhqEZJmVLT+n7tN5l4tKZZHq2d18s70MDbQcnaZUQu+uCT/gyesTMzDOye6sYq9TqAEf7GsvY3mxI0wYvx4cXB81zSunH6kCHg3J7XBSA9Sf0e7JiAOzpcDUhajRxfxLwWxdxcStKpyIUsV10L/sA0V2Q7rEVpEbAAvx6CFPRjFUUlYlBrasXpPUd2pHg8zkbcO1wfFiIOX4KN8ul6MFCwMGNKHW4ccnPLqXUd6B2cbn3YtyK/ffoVBHz200pGUa3Yo3Q9a85ZiugWfBEm7jbq3ywyidM66JphnlCCo5gzF27XM5Txvk3VgJiDUISDZIOFDF6bgfLJl+0qitEU= terraform"
} 

resource "aws_instance" "mvp-bastion" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.nano"
  key_name               = aws_key_pair.my.key_name
  subnet_id              = aws_subnet.mvp-frontend.id
  vpc_security_group_ids = [ aws_security_group.bastion.id ]
  user_data = file("prepareBastion.sh")

  tags = {
    Name = "mvp-bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.mvp-bastion.id
  tags = {
    Name = "mvp-bastion-eip"
  }
}

resource "aws_instance" "mvp-jenkins" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my.key_name
  subnet_id              = aws_subnet.mvp-backend.id
  vpc_security_group_ids = [ aws_security_group.jenkins.id ]
  user_data = file("prepareJenkinsMaster.sh")

  tags = {
    Name = "mvp-jenkins"
  }
}

output "mvp-bastion-private-ip" {
  value = aws_instance.mvp-bastion.private_ip
}

output "mvp-jenkins-private-ip" {
  value = aws_instance.mvp-jenkins.private_ip
}