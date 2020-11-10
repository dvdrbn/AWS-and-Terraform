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