variable "use_aurora" {
  description = "When true, create Aurora PostgreSQL cluster instead of a single RDS instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where database resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "engine" {
  description = "Database engine for non-Aurora RDS instance"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version to use (e.g., 14.10)"
  type        = string
}

variable "instance_class" {
  description = "Instance class (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Create a Multi-AZ RDS instance (non-Aurora only)"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "app"
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}


