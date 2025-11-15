locals {
  engine_effective  = var.use_aurora ? "aurora-postgresql" : var.engine
  engine_major      = regex("^\\d+", var.engine_version)
  pg_family         = "postgres${local.engine_major}"
  aurora_pg_family  = "aurora-postgresql${local.engine_major}"
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Allow PostgreSQL from inside VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_db_parameter_group" "postgres" {
  count  = var.use_aurora ? 0 : 1
  name   = "postgres-params"
  family = local.pg_family

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "log_statement"
    value = "none"
  }

  parameter {
    name  = "work_mem"
    value = "4MB"
  }

  tags = {
    Name = "postgres-params"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_pg" {
  count  = var.use_aurora ? 1 : 0
  name   = "aurora-postgresql-params"
  family = local.aurora_pg_family

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "log_statement"
    value = "none"
  }

  parameter {
    name  = "work_mem"
    value = "4MB"
  }

  tags = {
    Name = "aurora-postgresql-params"
  }
}


