module "vpc" {
  source       = "./modules/vpc"
  name         = local.env_name
  cidr_block   = "10.100.0.0/16"
  azs          = ["us-east-1a", "us-east-1b"]
  cidr_public  = ["10.100.1.0/24", "10.100.2.0/24"]
  cidr_private = ["10.100.100.0/24", "10.100.101.0/24"]
  tags         = local.common_tags
}