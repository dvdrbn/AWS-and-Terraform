terraform {
  required_version = ">= 0.13"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = merge(var.tags, { Name = "${var.name}-vpc" })
}