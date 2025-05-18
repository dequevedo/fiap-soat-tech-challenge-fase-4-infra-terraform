locals {
  region = "us-east-1"
  name   = "tech-challenge-cluster"
  vpc_cidr = "10.123.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = []
}

terraform {
  backend "s3" {
    bucket = "terraform-state-techchallenge"
    key    = "infraestrutura/state.tfstate"
    region = "us-east-1"
    encrypt = true
  }
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}