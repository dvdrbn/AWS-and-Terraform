##################################
# Security groups for instances
##################################
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

#####################################
# S3 access policy and role 
#####################################
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = var.assume_role_policy_data
  tags               = merge(local.common_tags, { Name = "${local.env_name}-role-s3access" })
}

resource "aws_iam_policy" "policy" {
  name        = "policy-role-allow-s3"
  description = "Allow role to access s3 buckets"
  policy      = data.template_file.policy_s3_access.rendered
}

resource "aws_iam_policy_attachment" "poicy_attach" {
  name       = "policy-role-allow-s3-attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}