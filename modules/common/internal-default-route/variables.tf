variable "private_route_table" {
  type        = string
  description = "Sets '0.0.0.0/0' route to the Gateway instance in the specified route table (e.g. vtb-12a34567)"
}

variable "internal_eni_id" {
  type        = string
  description = "The internal ENI of the security gateway (used as the next hop)"
}

variable "enable_ipv6" {
  type        = bool
  description = "Enable IPv6 (dual-stack) default route (::/0)."
  default     = false
}
