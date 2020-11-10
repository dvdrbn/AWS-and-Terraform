output "policy_data" {
  value = data.template_file.policy_s3_access.rendered
}

output "bucket_policy"{
    value = data.template_file.policy_s3_bucket.rendered
}