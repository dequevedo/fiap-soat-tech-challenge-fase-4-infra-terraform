resource "aws_security_group" "documentdb_sg" {
  name        = "documentdb-security-group"
  description = "Permitir acesso ao cluster DocumentDB na VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DocumentDB SG"
  }
}

resource "aws_docdb_subnet_group" "documentdb_subnet_group" {
  name       = "documentdb-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "DocumentDB Subnet Group"
  }
}

resource "aws_docdb_cluster" "documentdb_cluster" {
  cluster_identifier      = "tech-challenge-docdb"
  engine                  = "docdb"
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_docdb_subnet_group.documentdb_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.documentdb_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"

  tags = {
    Name = "Tech Challenge DocumentDB"
  }
}

resource "aws_docdb_cluster_instance" "documentdb_instance" {
  count              = 1
  identifier         = "tech-challenge-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.documentdb_cluster.id
  instance_class     = "db.t3.small"
  tags = {
    Name = "DocumentDB Instance ${count.index}"
  }
}
