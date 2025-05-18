variable "db_username" {}
variable "db_password" {}

data "aws_rds_engine_version" "latest_postgres" {
  engine = "postgres"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-tech-challenge-security-group"
  description = "Permitir acesso ao RDS na VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "rds_postgres" {
  identifier             = "tech-challenge-postgres"
  engine                 = "postgres"
  engine_version         = data.aws_rds_engine_version.latest_postgres.version
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "Tech Challenge RDS"
  }
}

# PostgreSQL Provider (criação dos bancos)
provider "postgresql" {
  host            = aws_db_instance.rds_postgres.address
  port            = 5432
  username        = var.db_username
  password        = var.db_password
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_database" "customer_db" {
  name             = "customer"
  owner            = var.db_username
  encoding         = "UTF8"
  lc_collate       = "en_US.UTF-8"
  lc_ctype         = "en_US.UTF-8"
  connection_limit = -1
}

resource "postgresql_database" "order_db" {
  name             = "order"
  owner            = var.db_username
  encoding         = "UTF8"
  lc_collate       = "en_US.UTF-8"
  lc_ctype         = "en_US.UTF-8"
  connection_limit = -1
}

resource "postgresql_database" "product_db" {
  name             = "product"
  owner            = var.db_username
  encoding         = "UTF8"
  lc_collate       = "en_US.UTF-8"
  lc_ctype         = "en_US.UTF-8"
  connection_limit = -1
}
