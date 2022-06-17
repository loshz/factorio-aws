variable "region" {
  type        = string
  description = "AWS region in which all resources will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
}
