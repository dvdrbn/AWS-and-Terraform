module "ec2_nginx" {
  source           = "./modules/ec2"
  name             = local.env_name
  subnets          = module.vpc.public_subnets
  ami_id           = data.aws_ami.ubuntu_1804.id
  key_name         = var.key_name
  security_groups  = [aws_security_group.sg.id]
  instance_type    = var.type_nginx
  instance_profile = aws_iam_instance_profile.instance_profile.name
  user_data        = var.nginx_install
  tags             = merge(local.common_tags, { purpose = "nginx" })
}

module "ec2_db" {
  source          = "./modules/ec2"
  name            = local.env_name
  subnets         = module.vpc.private_subnets
  ami_id          = data.aws_ami.ubuntu_1804.id
  key_name        = var.key_name
  security_groups = [aws_security_group.sg.id]
  instance_type   = var.type_db
  user_data       = var.db_install
  tags            = merge(local.common_tags, { purpose = "db" })
}

module "elb" {
  source          = "./modules/elb"
  name            = local.env_name
  instances       = module.ec2_nginx.instances
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.sg.id]
  tags            = merge(local.common_tags, { purpose = "nginx" })
}