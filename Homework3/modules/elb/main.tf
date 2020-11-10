terraform {
  required_version = ">= 0.13"
}

resource "aws_elb" "elb" {
  instances       = var.instances
  subnets         = var.subnets
  security_groups = var.security_groups

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
  tags = merge(var.tags, { Name = "${var.name}-${var.tags.purpose}-elb" })
}

resource "aws_lb_cookie_stickiness_policy" "sticky_cookie" {
  name                     = "${var.name}-${var.tags.purpose}-elb-sticky"
  load_balancer            = aws_elb.elb.id
  lb_port                  = 80
  cookie_expiration_period = 60
}