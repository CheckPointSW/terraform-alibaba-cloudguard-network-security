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
