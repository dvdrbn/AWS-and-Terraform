provider "aws" {
  region = var.aws_region
}

#####################################
# S3 bucket & policy
#####################################

resource "aws_s3_bucket" "b" {
  bucket = lower("${local.env_name}-nginx-accessLogs")
  tags   = merge(local.common_tags, { Name = "${local.env_name}-nginx-access-logs" })
}

resource "aws_s3_bucket_policy" "b_policy" {
  bucket = aws_s3_bucket.b.id
  policy = data.template_file.policy_s3_bucket.rendered
}

#####################################
# S3 access policy and role 
#####################################
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = var.assume_role_policy_data
  # add tags
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