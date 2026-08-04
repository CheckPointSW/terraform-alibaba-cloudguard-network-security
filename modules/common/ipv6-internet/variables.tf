variable "create_ipv6_gateway" {
  type        = bool
  description = "Whether to create a new IPv6 gateway (true for new VPC, false for existing VPC)."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to associate the IPv6 gateway with."
}

variable "ipv6_gateway_id" {
  type        = string
  description = "(Optional) Existing IPv6 gateway ID. Used when deploying into an existing VPC."
  default     = ""
}

variable "instance_id" {
  type        = string
  description = "The ECS instance ID whose IPv6 address will get internet bandwidth."
}

variable "vswitch_id" {
  type        = string
  description = "The vSwitch ID to filter the IPv6 address lookup."
}

variable "ipv6_internet_bandwidth" {
  type        = number
  description = "IPv6 internet bandwidth in Mbps."
}

variable "ipv6_internet_charge_type" {
  type        = string
  description = "Billing model for the IPv6 internet bandwidth. PayByTraffic = pay per GB transferred; PayByBandwidth = flat fee per reserved Mbps. ForceNew: changing this destroys + recreates the bandwidth allocation."
  default     = "PayByTraffic"
}

variable "ipv6_gateway_name" {
  type        = string
  description = "Name for the IPv6 gateway resource."
  default     = "ipv6-gw"
}
