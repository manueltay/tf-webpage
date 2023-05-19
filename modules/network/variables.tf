variable "vpc_cidr" {
  description = "Type the VPC CIDR"
}

variable "environment" {
  description = "Type the environment name"
  default     = "dev"
}

variable "if_private_subnets" {
  type        = bool
  default     = true
  description = "set false to dont create any private subnet"
}

variable "test" {}
