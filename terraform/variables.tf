locals {
  # Tags are metadata stored on AWS resources.
  # They are particularly useful for billing and querying purposes.
  # Reference: https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html
  tags = {
    "terraform.io/managed" = "true"
    "factorio.com/version" = var.factorio_version
  }
}

variable "s3_bucket" {
  type        = string
  description = "AWS S3 bucket name for storing state and other configs"
}

variable "region" {
  type        = string
  description = "AWS region in which all resources will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "172.16.0.0/16"
}

variable "ec2_instance_type" {
  type        = string
  description = "AWS instance type of the EC2 VM"
  default     = "t3.medium"
}

variable "factorio_version" {
  type        = string
  description = "Factorio Headless Server version"
  default     = "1.1.59"
}
