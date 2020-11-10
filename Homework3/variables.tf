variable "key_name" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "cidr_vpc" {
  type    = string
  default = "10.100.0.0/16"
}

variable "cidr_public" {
  type    = list(string)
  default = ["10.100.1.0/24", "10.100.2.0/24"]
}

variable "cidr_private" {
  type    = list(string)
  default = ["10.100.10.0/24", "10.100.11.0/24"]
}

locals {
  env_name = "Homework3"
  common_tags = {
    project = "Project"
  }
}

variable "type_nginx" {
  description = "Type for nginx servers"
  type = string
  default = "t2.micro"
}

variable "type_db" {
  description = "Type for db servers"
  type = string
  default = "t2.micro"
}

variable "nginx_install" {
  description = "User data for nginx servers"
  type = string
  default = <<-EOF
      #! /bin/bash

      sudo apt update
      sudo apt install nginx awscli -y

      sudo sed -i 's/nginx/OpsSchool Rules/g' /var/www/html/index.nginx-debian.html
      sudo sed -i '15,23d' /var/www/html/index.nginx-debian.html
      sudo sed -i "14 a $HOSTNAME" /var/www/html/index.nginx-debian.html

      service nginx restart

      crontab -l | { cat; echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://homework3-nginx-access-logs/$HOSTNAME/"; } | crontab -
  EOF
}

variable "db_install" {
  description = "User data for db servers"
  type = string
  default = ""
}

variable "assume_role_policy_data" {
  type    = string
  default = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
    ]
  }
  EOF
}