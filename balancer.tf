# Security Group para o NLB
resource "aws_security_group" "product_nlb_sg" {
  name        = "product-nlb-sg"
  description = "Security group for the product service NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 30080
    to_port     = 30080
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
    Name = "product-nlb-sg"
  }
}

# NLB para o Ingress Controller
resource "aws_lb" "product_nlb" {
  name               = "product-nlb"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.product_nlb_sg.id]
  subnets            = module.vpc.private_subnets
  enable_deletion_protection = false

  tags = {
    Name = "product-nlb"
  }
}

# Target Group do tipo instance
resource "aws_lb_target_group" "product_target_group" {
  name        = "product-target-group"
  protocol    = "HTTP"
  port        = 30080
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    port                = "30080"
    path                = "/actuator/health"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "product-target-group"
  }
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [local.name]
  }
}

resource "aws_lb_target_group_attachment" "product_targets" {
  for_each = toset(data.aws_instances.eks_nodes.ids)

  target_group_arn = aws_lb_target_group.product_target_group.arn
  target_id        = each.value
  port             = 30080
}

# Listener do NLB na porta 80 (TCP)
resource "aws_lb_listener" "product_listener" {
  load_balancer_arn = aws_lb.product_nlb.arn
  port              = 80
  protocol          = "TCP"  # ✅ NLB só permite TCP, UDP, TLS, etc.

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_target_group.arn
  }
}
