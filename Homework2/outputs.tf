##########################
# Network outputs
##########################

output "vpc_id" {
    description = "Print ID of vpc"
    value = aws_vpc.vpc.id
}

output "subnet_public" {
    value = aws_subnet.subnet_public[*].id
}

output "subnet_private" {
    value = aws_subnet.subnet_private[*].id
}

output "igw" {
    value = aws_internet_gateway.igw.id
}

output "eip_ngw" {
    value = aws_eip.eip_ngw[*].id
}

output "ngw" {
    value = aws_nat_gateway.ngw[*].id
}

output "rt_public" {
    value = aws_route_table.rt_public.id
}

output "rt_private" {
    value = aws_route_table.rt_private[*].id
}

##########################
# Instances
##########################
output "nginx_public_ip" {
    value = aws_instance.nginx[*].public_ip
}

output "db_public_ip" {
    value = aws_instance.db[*].public_ip
}

output "elb_public_dns" {
    value = aws_elb.elb.dns_name
}