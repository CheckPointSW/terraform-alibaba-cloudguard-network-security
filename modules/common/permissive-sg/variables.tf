variable "vpc_id" {
  type        = string
  description = "The VPC ID in which to create the security group"
}

variable "resources_tag_name" {
  type        = string
  description = "(Optional) Name tag prefix for the security group"
  default     = ""
}

variable "gateway_name" {
  type        = string
  description = "(Optional) Fallback name when resources_tag_name is empty"
  default     = "Check-Point-Gateway-tf"
}

variable "enable_ipv6" {
  type        = bool
  description = "Enable IPv6 (dual-stack) security group rules."
  default     = false
}
