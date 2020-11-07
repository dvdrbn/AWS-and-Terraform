provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source     = "./modules/vpc"
  name       = "Homework3"
  cidr_block = "10.0.0.0/16"
  tags = {
    purpose = "Learning"
  }
}