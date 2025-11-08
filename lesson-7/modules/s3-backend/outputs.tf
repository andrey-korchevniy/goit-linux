output "s3_bucket_url" {
  description = "S3 bucket regional URL for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locks"
  value       = aws_dynamodb_table.terraform_locks.name
}


