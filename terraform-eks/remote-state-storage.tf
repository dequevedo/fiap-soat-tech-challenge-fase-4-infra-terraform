resource "aws_s3_bucket" "terraform_remote_state_bucket" {
  bucket = "terraform-state-techchallenge"
  force_destroy = false

  tags = {
    Name        = "Terraform State Storage"
    Environment = "dev"
    Purpose     = "Armazenar terraform.tfstate remoto"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_remote_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_remote_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
