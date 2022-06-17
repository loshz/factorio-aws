terraform {
  required_version = "~> 1.2"

  backend "s3" {
    key     = "factorio.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.19.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.1"
    }
  }
}

provider "aws" {
  region = var.region
}
