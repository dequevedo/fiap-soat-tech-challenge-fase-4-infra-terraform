resource "aws_security_group" "mongo_sg" {
  name        = "mongo-ec2-sg"
  description = "Allow MongoDB access within VPC, port 27017"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MongoDB access within VPC"
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
    Name = "mongo-ec2-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "mongo" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y gnupg curl
              curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
                gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
              echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
                tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              apt-get update
              apt-get install -y mongodb-org
              systemctl start mongod
              systemctl enable mongod
              EOF

  tags = {
    Name = "MongoDB EC2"
  }
}
