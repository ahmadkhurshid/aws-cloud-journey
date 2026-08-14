variable "vpc_cidr" {
  description = "Address range for the VPC"
  type        = string
}

variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}