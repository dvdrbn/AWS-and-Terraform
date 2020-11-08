output "instances" {
  description = "List of ec2 instance IDs"
  value       = aws_instance.ec2.*.id
}