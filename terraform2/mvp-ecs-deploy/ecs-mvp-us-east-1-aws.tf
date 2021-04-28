variable "aws_access_key"     { type = string }
variable "aws_secret_key"     { type = string }

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

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allow SSH and OpenVPN inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.mvp-vpc-id

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

data "aws_iam_policy_document" "mvp_ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mvp_ecs_agent" {
  name               = "mvp-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.mvp_ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "mvp_ecs_agent" {
  role       = aws_iam_role.mvp_ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "mvp_ecs_agent" {
  name = "mvp-ecs-agent"
  role = aws_iam_role.mvp_ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-0742b4e673072066f" # Amazon Linux 2
    iam_instance_profile = aws_iam_instance_profile.mvp_ecs_agent.name
    security_groups      = [aws_security_group.ecs.id]
    user_data            = file("./prepareECS.sh")
    instance_type        = "t2.medium"
    key_name             = "zoltan.kiss_training_terraform"
    associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "mvp-ecs" {
    name                      = "mvp-ecs"
    vpc_zone_identifier       = [data.terraform_remote_state.network.outputs.mvp-frontendsubnet-id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

resource "aws_ecs_cluster" "mvp" {
    name  = "mvp"
}

output "mvp-ecs-cluster-id" {
  value = aws_ecs_cluster.mvp.id
}

# output "mvp-ecs-private-ip" {
#  value = aws_instance.mvp-mysql.private_ip
#}