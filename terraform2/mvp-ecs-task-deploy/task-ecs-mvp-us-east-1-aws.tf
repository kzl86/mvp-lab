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
    key    = "mvp-lab-ecs-task"
    region = "us-east-1"
  }
}

# is this needed?
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "kiss-mvp"
    key    = "mvp-lab"
    region = "us-east-1"
  }
}

# is this needed?
data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "kiss-mvp"
    key    = "mvp-lab-ecs"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "kiss-mvp"
    key    = "mvp-lab-ecr"
    region = "us-east-1"
  }
}

resource "aws_ecs_task_definition" "mvp" {
  family                = "mvp"
  container_definitions = <<TASK_DEFINITION
[
    {
        "cpu": 2,
        "essential": true,
        "image": "${data.terraform_remote_state.ecr.outputs.mvp-wordpress-repository-url}:latest",
        "memory": 300,
        "name": "wordpress",
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 80
            }
        ],
        "mountPoints": [
          {
            "sourceVolume": "nfs",
            "containerPath": "/usr/share/wordpress/wp-content/images"
          }
        ]
    }
]
TASK_DEFINITION

  volume {
    name = "nfs"
    host_path = "/media/nfs/"
  }

}

resource "aws_ecs_service" "mvp" {
  name            = "mvp"
  cluster         = data.terraform_remote_state.ecs.outputs.mvp-ecs-cluster-id
  task_definition = aws_ecs_task_definition.mvp.arn
  desired_count   = 1
}