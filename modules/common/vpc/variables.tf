variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}

variable "public_vswitchs_map" {
  type        = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a public vSwitch. (e.g. {\"cn-hangzhou-e\" = 1})"
}

variable "management_vswitchs_map" {
  type        = map(string)
  description = "(Optional) A map of pairs {availability-zone = vswitch-suffix-number} for management vSwitches."
  default     = {}
}

variable "private_vswitchs_map" {
  type        = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a private vSwitch. (e.g. {\"cn-hangzhou-f\" = 3})"
  default     = {}
}

variable "vswitchs_bit_length" {
  type        = number
  description = "Number of additional bits with which to extend the vpc_cidr. For example, if vpc_cidr ends in /16 and vswitchs_bit_length is 8, resulting vSwitch addresses will have length /24"
}
