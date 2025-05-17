resource "aws_security_group" "eks_sg" {
  name        = "eks-cluster-sg"
  description = "Security Group fixo para o cluster EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 30080
    to_port     = 30080
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

resource "aws_security_group_rule" "allow_eks_30090" {
  type              = "ingress"
  from_port         = 30080
  to_port           = 30080
  protocol         = "TCP"
  security_group_id = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.sg.id
}