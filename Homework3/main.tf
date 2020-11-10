terraform {
  backend "s3" {
    bucket = "homework3-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "homework3-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
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

  tags = merge(local.common_tags, { Name = "${local.env_name}-dynoDB-locks" })
}