module "s3_backend" {
  source = "./modules/s3-backend"                # Шлях до модуля
  bucket_name = "terraform-state-bucket-001001"  # Ім'я S3-бакета
  table_name  = "terraform-locks"                # Ім'я DynamoDB
}

# Use existing VPC from lesson-5 by tags (no new VPC creation here)
data "aws_vpc" "lesson5" {
  tags = {
    Name = "vpc-vpc"
  }
}

# Fetch public subnets from the existing VPC by exact Name tags
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lesson5.id]
  }
  filter {
    name   = "tag:Name"
    values = ["vpc-public-subnet-1", "vpc-public-subnet-2", "vpc-public-subnet-3"]
  }
}

module "ecr" {
  source          = "./modules/ecr"   # Шлях до модуля
  repository_name = "app-repo"        # Назва репозиторію
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"            # Назва кластера
  subnet_ids      = data.aws_subnets.public.ids   # ID підмереж з існуючої VPC (lesson-5)
  instance_type   = "t2.micro"                    # Тип інстансів
  desired_size    = 1                             # Бажана кількість нодів
  max_size        = 2                             # Максимальна кількість нодів
  min_size        = 1                             # Мінімальна кількість нодів
}
