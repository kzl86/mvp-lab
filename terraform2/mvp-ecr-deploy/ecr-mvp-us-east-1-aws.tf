provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket = "kiss-mvp"
    key    = "mvp-lab-ecr"
    region = "us-east-1"
  }
}

variable "aws_access_key"     { type = string }
variable "aws_secret_key"     { type = string }

resource "aws_ecr_repository" "wordpress" {
  name                 = "mvp-wordpress"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "tomcat" {
  name                 = "mvp-tomcat"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "mvp-wordpress-repository-url" {
  value = aws_ecr_repository.wordpress.repository_url
}

output "mvp-tomcat-repository-url" {
  value = aws_ecr_repository.tomcat.repository_url
}