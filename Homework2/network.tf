#  
# Create a VPC with 2 subnets (public / private) at each availability zone
#

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  tags = merge(local.common_tags, {Name = "${local.env_name}-vpc"})
}

resource "aws_subnet" "subnet_public" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_public[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {Name = "${local.env_name}-sub-public-${count.index}"})
}

resource "aws_subnet" "subnet_private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_private[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {Name = "${local.env_name}-sub-private-${count.index}"})
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, {Name = "${local.env_name}-igw"})
}

resource "aws_eip" "eip_ngw" {
  count = length(var.availability_zones)
  vpc = true
  tags = merge(local.common_tags, {Name = "${local.env_name}-eip-ngw-${count.index}"})
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.eip_ngw[count.index].id
  subnet_id     = aws_subnet.subnet_public[count.index].id
  tags = merge(local.common_tags, {Name = "${local.env_name}-ngw-${count.index}"})
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  depends_on = [aws_internet_gateway.igw]
  tags = merge(local.common_tags, {Name = "${local.env_name}-rt-public"})
}

resource "aws_route_table" "rt_private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = merge(local.common_tags, {Name = "${local.env_name}-rt-private-${count.index}"})
}

resource "aws_route_table_association" "rta_public" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.rt_public.id
  depends_on = [aws_route_table.rt_public]
}

resource "aws_route_table_association" "rta_private" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id
}