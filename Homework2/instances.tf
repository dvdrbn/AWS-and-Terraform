##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region     = var.aws_region
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_instance" "nginx" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.ubuntu_1804.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnet_public[count.index].id
  depends_on             = [aws_route_table.rt_public]
  user_data              = local.nginx_install
  tags                   = merge(local.common_tags, {Name = "${local.env_name}-nginx-${count.index}"})
  provisioner "local-exec" {
    command = "ping -c 4 www.google.com"
  }
}

resource "aws_instance" "db" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.ubuntu_1804.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.subnet_private[count.index].id
  depends_on             = [aws_nat_gateway.ngw]
  tags                   = merge(local.common_tags, {Name = "${local.env_name}-db-${count.index}"})

  provisioner "local-exec" {
    command = "ping -c 4 www.google.com"
  }
}

resource "aws_elb" "elb" {
  name = "homework2-elb"
  instances = aws_instance.nginx[*].id
  subnets = aws_subnet.subnet_public[*].id
  security_groups = [aws_security_group.sg.id]

  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  tags = merge(local.common_tags, {Name = "${local.env_name}-elb"})
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, {Name = "${local.env_name}-sg"})
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