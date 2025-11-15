output "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state files"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

#-------------VPC-----------------

output "vpc_id" {
  description = "ID of the existing VPC from lesson-5"
  value       = data.aws_vpc.lesson5.id
}

output "public_subnets" {
  description = "List of public subnet IDs from lesson-5 VPC"
  value       = data.aws_subnets.public.ids
}

# Private subnets are not used directly here; keep empty to match interface
output "private_subnets" {
  description = "List of private subnet IDs (not queried here)"
  value       = []
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.lesson5.id]
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the lesson-5 VPC"
  value       = data.aws_internet_gateway.igw.id
}

#-------------ECR-----------------

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = module.ecr.repository_url
}

#-------------EKS-----------------

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

