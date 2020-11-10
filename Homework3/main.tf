# terraform {
#   # backend "s3" {
#   #   bucket = "homework3-terraform-state"
#   #   key    = "global/s3/terraform.tfstate"
#   #   region = "us-east-1"

#   #   dynamodb_table = "homework3-terraform-locks"
#   #   encrypt        = true
#   # }
# }

provider "aws" {
  region = var.aws_region
}

#####################################
# S3 bucket & policy
#####################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = lower("${local.env_name}-terraform-state")

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(local.common_tags, { Name = "${local.env_name}-s3-terraform-state" })
}

resource "aws_s3_bucket" "b" {
  bucket = lower("${local.env_name}-nginx-access-logs")
  tags   = merge(local.common_tags, { Name = "${local.env_name}-s3-nginx-access-logs" })
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
  tags   = merge(local.common_tags, { Name = "${local.env_name}-role-s3access" })
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

#####################################
# DynamoDB
#####################################
resource "aws_dynamodb_table" "terraform_locks" {
  name         = lower("${local.env_name}-terraform-locks")
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags   = merge(local.common_tags, { Name = "${local.env_name}-dynodb-locks" })
}