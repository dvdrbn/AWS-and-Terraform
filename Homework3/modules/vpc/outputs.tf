output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.vpc.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.subnet_public.*.id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.subnet_private.*.id
}