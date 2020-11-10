# output "policy_data" {
#   value = data.template_file.policy_s3_access.rendered
# }

# output "bucket_policy" {
#   value = data.template_file.policy_s3_bucket.rendered
# }

output "nginx-ips" {
  value = module.ec2_nginx.public_ips
}

output "db-ips" {
  value = module.ec2_db.private_ips
}

output "elb_public_dns" {
  value = module.elb.elb_public_dns
}