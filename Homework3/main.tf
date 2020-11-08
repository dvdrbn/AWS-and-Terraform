provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu_1804" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

module "vpc" {
  source       = "./modules/vpc"
  name         = local.env_name
  cidr_block   = "10.100.0.0/16"
  azs          = ["us-east-1a", "us-east-1b"]
  cidr_public  = ["10.100.1.0/24", "10.100.2.0/24"]
  cidr_private = ["10.100.100.0/24", "10.100.101.0/24"]
  tags         = local.common_tags
}

module "ec2-nginx" {
  source          = "./modules/ec2"
  name            = local.env_name
  subnets         = module.vpc.public_subnets
  ami_id          = data.aws_ami.ubuntu_1804.id
  key_name        = var.key_name
  security_groups = [aws_security_group.sg.id]
  instance_type   = "t2.micro"
  user_data       = ""
  tags            = merge(local.common_tags, { purpose = "Nginx" })
}

module "ec2-db" {
  source          = "./modules/ec2"
  name            = local.env_name
  subnets         = module.vpc.private_subnets
  ami_id          = data.aws_ami.ubuntu_1804.id
  key_name        = var.key_name
  security_groups = [aws_security_group.sg.id]
  instance_type   = "t2.micro"
  user_data       = ""
  tags            = merge(local.common_tags, { purpose = "db" })
}

resource "aws_security_group" "sg" {
  vpc_id = module.vpc.vpc_id
  tags   = merge(local.common_tags, { Name = "${local.env_name}-sg" })
}

resource "aws_security_group_rule" "http_acess" {
  description       = "allow http access from anywhere"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}