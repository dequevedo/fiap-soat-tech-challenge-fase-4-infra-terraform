## Security Group para o NLB
#resource "aws_security_group" "product_nlb_sg" {
#  name        = "product-nlb-sg"
#  description = "Security group for the product service NLB"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "TCP"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "product-nlb-sg"
#  }
#}
#
## NLB para o Ingress Controller
#resource "aws_lb" "product_nlb" {
#  name               = "product-nlb"
#  internal           = false
#  load_balancer_type = "network"
#  security_groups    = [aws_security_group.product_nlb_sg.id]
#  subnets            = module.vpc.private_subnets
#  enable_deletion_protection = false
#
#  tags = {
#    Name = "product-nlb"
#  }
#}
#
## Target Group com protocolo TCP
#resource "aws_lb_target_group" "product_target_group" {
#  name        = "product-target-group"
#  protocol    = "TCP"
#  port        = 30080
#  vpc_id      = module.vpc.vpc_id
#  target_type = "instance"
#
#  health_check {
#    protocol            = "TCP"
#    port                = "30080"
#    interval            = 10
#    timeout             = 5
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#  }
#
#  tags = {
#    Name = "product-target-group"
#  }
#}
#
## Descobrir instâncias EC2 do cluster EKS
#data "aws_instances" "eks_nodes" {
#  filter {
#    name   = "tag:eks:cluster-name"
#    values = [local.name]
#  }
#
#  filter {
#    name   = "instance-state-name"
#    values = ["running"]
#  }
#}
#
## Associar EC2 instances como targets
#resource "aws_lb_target_group_attachment" "product_targets" {
#  for_each = toset(data.aws_instances.eks_nodes.ids)
#
#  target_group_arn = aws_lb_target_group.product_target_group.arn
#  target_id        = each.value
#  port             = 30080
#}
#
## Listener TCP:80 do NLB
#resource "aws_lb_listener" "product_listener" {
#  load_balancer_arn = aws_lb.product_nlb.arn
#  port              = 80
#  protocol          = "TCP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.product_target_group.arn
#  }
#}
