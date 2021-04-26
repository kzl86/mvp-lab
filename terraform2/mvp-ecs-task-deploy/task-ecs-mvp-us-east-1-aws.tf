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