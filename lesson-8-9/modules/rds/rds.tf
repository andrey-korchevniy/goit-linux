resource "aws_db_instance" "this" {
  count                  = var.use_aurora ? 0 : 1
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  allocated_storage      = 20
  storage_encrypted      = true
  skip_final_snapshot    = true
  multi_az               = var.multi_az
  publicly_accessible    = false
  apply_immediately      = true

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 5432

  parameter_group_name   = aws_db_parameter_group.postgres[0].name

  tags = {
    Name = "rds-${var.engine}"
  }
}


