resource "aws_instance" "mvp-jenkins" {
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t2.nano"
  key_name               = aws_key_pair.my.key_name
  subnet_id              = aws_subnet.mvp-backend.id
  vpc_security_group_ids = [ aws_security_group.jenkins.id ]

  tags = {
    Name = "mvp-jenkins"
  }
}