# Security Group para o Load Balancer
resource "aws_security_group" "sg" {
  name        = "tech-challenge-nlb-sg"
  description = "Security group for the internal NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 80 de qualquer IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 443 de qualquer IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 8080 de qualquer IP
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 8081 de qualquer IP
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]  # Permite tráfego na porta 8082 de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech-challenge-nlb-sg"
  }
}

# Load Balancer Interno (NLB)
resource "aws_lb" "internal_nlb" {
  name               = "tech-challenge-nlb-internal"
  internal           = true  # Define como Load Balancer interno
  load_balancer_type = "network"
  security_groups    = [aws_security_group.sg.id]
  subnets            = module.vpc.private_subnets

  enable_deletion_protection = false

  tags = {
    Name = "tech-challenge-lb-internal"
  }
}

# Target Group para API Products (porta 8080)
resource "aws_lb_target_group" "product_target_group" {
  name     = "product-target-group"
  port     = 8080
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 30
    path     = "/actuator/health"
    port     = 30080
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target Group para API Customers (porta 8081)
resource "aws_lb_target_group" "customer_target_group" {
  name     = "customer-target-group"
  port     = 8081
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 30
    path     = "/actuator/health"
    port     = 8081
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target Group para API Orders (porta 8082)
resource "aws_lb_target_group" "order_target_group" {
  name     = "order-target-group"
  port     = 8082
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 30
    path     = "/actuator/health"
    port     = 8082
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener para a porta 8080
resource "aws_lb_listener" "listener_8080" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_target_group.arn
  }
}

# Listener para a porta 8081
resource "aws_lb_listener" "listener_8081" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "8081"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer_target_group.arn
  }
}

# Listener para a porta 8082
resource "aws_lb_listener" "listener_8082" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "8082"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order_target_group.arn
  }
}

# Listener para a porta 80 (HTTP)
resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_target_group.arn
  }
}

# Listener para a porta 443 (HTTPS)
resource "aws_lb_listener" "listener_443" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_target_group.arn
  }
}
