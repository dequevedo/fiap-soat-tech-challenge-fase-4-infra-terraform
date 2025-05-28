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

# NLB para o Ingress Controller
resource "aws_lb" "ingress_nlb" {
  name               = "tech-challenge-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.ingress_nlb_sg.id]
  subnets = module.vpc.public_subnets ### TODO alterar para private assim que o GTW funcionar
  enable_deletion_protection = false

  tags = {
    Name = "tech-challenge-nlb"
  }
}

# Target Group para o Ingress Controller
resource "aws_lb_target_group" "ingress_target_group" {
  name        = "ingress-target-group"
  protocol    = "TCP"
  port        = 30080
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "30080"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ingress-target-group"
  }
}

# Listener TCP:80 do NLB
resource "aws_lb_listener" "ingress_listener" {
  load_balancer_arn = aws_lb.ingress_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_target_group.arn
  }
}

# Associação do Node do Ingress como Target do Target Group
data "aws_instances" "ingress_nodes" {
  filter {
    name   = "tag:Name"
    values = ["ingress-nodegroup"]
  }
}

resource "aws_lb_target_group_attachment" "ingress_target" {
  target_group_arn = aws_lb_target_group.ingress_target_group.arn
  target_id        = data.aws_instances.ingress_nodes.ids[0]
  port             = 30080
}