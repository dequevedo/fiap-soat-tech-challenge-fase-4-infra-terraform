# Security Group para o NLB do Ingress
resource "aws_security_group" "ingress_nlb_sg" {
  name        = "ingress-nlb-sg"
  description = "Security group for the Ingress NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ingress-nlb-sg"
  }
}
