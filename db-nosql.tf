resource "aws_dynamodb_table" "orders_table" {
  name           = "orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  tags = {
    Environment = "production"
    Project     = "tech-challenge"
  }
}