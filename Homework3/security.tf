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