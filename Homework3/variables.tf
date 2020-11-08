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
  db_install    = ""
  nginx_install = ""
  #   nginx_install = <<-EOF
  #     #! /bin/bash

  #     sudo apt install nginx -y
  #     service nginx restart
  #     EOF
}