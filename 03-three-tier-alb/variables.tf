variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "tf"
}

variable "vpc_cidr" {
  description = "Address range for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance size for the web servers"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name, used in tags"
  type        = string
  default     = "dev"
}