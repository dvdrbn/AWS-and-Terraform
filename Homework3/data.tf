data "aws_ami" "ubuntu_1804" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "template_file" "policy_s3_access" {
  template = file("policy_s3_access.json.tpl")

  vars = {
    s3_bucket_arn = aws_s3_bucket.b.arn
  }
}

data "template_file" "policy_s3_bucket" {
  template = file("policy_s3_bucket.tpl")

  vars = {
    s3_bucket_arn = aws_s3_bucket.b.arn
    role_arn = aws_iam_role.ec2_s3_access_role.arn
  }
}