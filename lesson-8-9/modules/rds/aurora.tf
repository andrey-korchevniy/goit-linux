resource "aws_rds_cluster" "this" {
  count                   = var.use_aurora ? 1 : 0
  engine                  = "aurora-postgresql"
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  storage_encrypted       = true
  skip_final_snapshot     = true
  port                    = 5432
  apply_immediately       = true
  cluster_identifier      = "aurora-pg-cluster"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg[0].name

  tags = {
    Name = "aurora-postgresql-cluster"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  count               = var.use_aurora ? 1 : 0
  identifier          = "aurora-pg-writer-1"
  cluster_identifier  = aws_rds_cluster.this[0].id
  instance_class      = var.instance_class
  engine              = "aurora-postgresql"
  publicly_accessible = false

  # Aurora instances inherit subnet group from cluster
  tags = {
    Name = "aurora-pg-writer-1"
  }
}


