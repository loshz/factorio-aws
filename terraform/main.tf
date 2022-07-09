terraform {
  required_version = "~> 1.2"

  backend "s3" {
    key     = "factorio.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}
