provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "./modules/vpc"
  name        = "Homework3"
  cidr_block  = "10.100.0.0/16"
  azs         = ["us-east-1a", "us-east-1b"]
  cidr_public = ["10.100.1.0/24", "10.100.2.0/24"]
  tags = {
    purpose = "Learning"
  }
}