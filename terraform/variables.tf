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
  default     = "172.25.16.0/24"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "ec2_ami" {
  type        = string
  description = "AMI of the EC2 VM"
  default     = null
}

variable "ec2_instance_type" {
  type        = string
  description = "AWS instance type of the EC2 VM"
  default     = "t3a.medium"
}

variable "ec2_volume_size" {
  type        = number
  description = "Size (GiB) of the root EC2 volume"
  default     = 20

  validation {
    condition     = var.ec2_volume_size >= 10
    error_message = "Must be greater than or equal to 10 (GiB)."
  }
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "List of IPv4 CIDRs of the allowed ingress traffic"
  default     = ["0.0.0.0/0"]

  validation {
    condition = length(var.ingress_cidrs) > 0 && alltrue([
      for a in var.ingress_cidrs : can(cidrnetmask(a))
    ])
    error_message = "List must not be empty and all addresses must be in valid IPv4 CIDR notation."
  }
}

variable "ingress_cidrs_ipv6" {
  type        = list(string)
  description = "List of IPv6 CIDRs of the allowed ingress traffic"
  default     = ["::/0"]
}

variable "factorio_version" {
  type        = string
  description = "Factorio version"
  default     = "latest"
}
