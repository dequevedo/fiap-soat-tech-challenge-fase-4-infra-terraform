variable "microservices" {
  default = [
    "fiap-soat-tech-challenge-product-api",
    "fiap-soat-tech-challenge-payment-api",
    "fiap-soat-tech-challenge-order-api",
    "fiap-soat-tech-challenge-customer-api"
  ]
}

resource "aws_ecr_repository" "tech_challenge_repos" {
  for_each = toset(var.microservices)

  name = "tech-challenge/${each.value}"

  image_scanning_configuration {
    scan_on_push = true
  }
}
