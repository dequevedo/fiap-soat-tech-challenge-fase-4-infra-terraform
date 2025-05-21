resource "aws_security_group" "eks_sg" {
  name        = "eks-cluster-sg"
  description = "Security Group fixo para o cluster EKS"
  vpc_id      = module.vpc.vpc_id

  # Permitir tráfego nas portas 8080, 8081, 8082 para os pods
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego de qualquer origem
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego de qualquer origem
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego de qualquer origem
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
