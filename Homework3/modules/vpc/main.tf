terraform {
  required_version = ">= 0.13"
}

##############################
# VPC
##############################
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = merge(var.tags, { Name = "${var.name}-vpc" })
}

##############################
# Subnet - Public
##############################
resource "aws_subnet" "subnet_public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name}-subnet-public-${count.index}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

##############################
# Route - Public
##############################
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "${var.name}-rt-public" })
}

resource "aws_route_table_association" "rta_public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

##############################
# Subnet - Private
##############################
resource "aws_subnet" "subnet_private" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_private[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.name}-subnet-private-${count.index}" })
}

###################################
# NAT gateway (for private subnets)
###################################
resource "aws_eip" "eip_ngw" {
  count = length(var.azs)
  vpc   = true
  tags  = merge(var.tags, { Name = "${var.name}-eip-ngw-${count.index}" })
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.azs)
  allocation_id = aws_eip.eip_ngw[count.index].id
  subnet_id     = aws_subnet.subnet_public[count.index].id
  tags          = merge(var.tags, { Name = "${var.name}-ngw-${count.index}" })
}

##############################
# Route - Private
##############################
resource "aws_route_table" "rt_private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = merge(var.tags, { Name = "${var.name}-rt-public-${count.index}" })
}

resource "aws_route_table_association" "rta_private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id
}