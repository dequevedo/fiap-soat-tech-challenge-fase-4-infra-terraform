# Security Group para o NLB
resource "aws_security_group" "product_nlb_sg" {
  name        = "product-nlb-sg"
  description = "Security group for the product service NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 8080 de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "product-nlb-sg"
  }
}

# NLB para o microserviço de Product
resource "aws_lb" "product_nlb" {
  name               = "product-nlb"
  internal           = true  # Define como NLB interno
  load_balancer_type = "network"
  security_groups    = [aws_security_group.product_nlb_sg.id]
  subnets            = module.vpc.private_subnets

  enable_deletion_protection = false

  tags = {
    Name = "product-nlb"
  }
}

# Target Group para o microserviço de Product
resource "aws_lb_target_group" "product_target_group" {
  name     = "product-target-group"
  port     = 8080
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 30
    path     = "/actuator/health"
    port     = 8080
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener para o NLB do Product (porta 8080)
resource "aws_lb_listener" "product_listener" {
  load_balancer_arn = aws_lb.product_nlb.arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_target_group.arn
  }
}
