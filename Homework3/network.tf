module "vpc" {
  source       = "./modules/vpc"
  name         = local.env_name
  cidr_block   = var.cidr_vpc
  azs          = var.availability_zones
  cidr_public  = var.cidr_public
  cidr_private = var.cidr_private
  tags         = local.common_tags
}