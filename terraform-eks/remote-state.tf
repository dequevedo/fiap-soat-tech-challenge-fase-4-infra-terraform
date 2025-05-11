terraform {
  backend "s3" {
    bucket = "terraform-state-techchallenge"
    key    = "infraestrutura/state.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
