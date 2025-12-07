###############################################
# Security Group for RDS
###############################################
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound access to RDS from VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow MySQL/Postgres from VPC"
    from_port   = 5432 # Default for Postgres, change to 3306 for MySQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

###############################################
# DB Subnet Group (Requires subnets in >= 2 AZs)
###############################################
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

###############################################
# RDS Instance (PostgreSQL)
###############################################
resource "aws_db_instance" "default" {
  identifier           = "main-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15" # Check for latest supported version
  instance_class       = "db.t3.micro"
  username             = "dbadmin"
  password             = var.db_password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  publicly_accessible  = false
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "main-db"
  }
}
