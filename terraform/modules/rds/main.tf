resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-db-subnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.cluster_name}-db-subnet"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    description     = "PostgreSQL access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

resource "aws_db_instance" "primary" {
  identifier     = "${var.cluster_name}-primary"
  engine         = "postgres"
  engine_version = "15.4"

  # Cheapest configuration
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp2"

  db_name  = "ecommerce"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name        = "${var.cluster_name}-primary"
    Environment = var.environment
  }
}

resource "aws_db_instance" "read_replica" {
  identifier     = "${var.cluster_name}-read-replica"
  instance_class = "db.t3.micro"

  replicate_source_db = aws_db_instance.primary.identifier

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.cluster_name}-read-replica"
    Environment = var.environment
  }
}
