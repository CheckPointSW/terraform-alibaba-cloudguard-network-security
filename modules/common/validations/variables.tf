variable "chkp_type" {
  type        = string
  description = "The Check Point machine type: 'gateway' or 'management'"
}

variable "instance_type" {
  type        = string
  description = "Alicloud instance type to validate against allowed list for chkp_type"
}

variable "version_license" {
  type        = string
  description = "Version and license string to validate against allowed list for chkp_type"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB — must be at least 100"
  default     = 200
}

variable "admin_shell" {
  type        = string
  description = "Admin shell to validate"
  default     = "/etc/cli.sh"
}

variable "hostname" {
  type        = string
  description = "(Optional) Hostname to validate — empty string skips validation"
  default     = ""
}

variable "sic_key" {
  type        = string
  description = "(Optional) SIC key to validate — empty string skips validation"
  default     = ""
  sensitive   = true
}

variable "token" {
  type        = string
  description = "(Optional) Smart-1 Cloud token to validate — empty string skips validation"
  default     = ""
  sensitive   = true
}

variable "password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash (use 'openssl passwd -6 PASSWORD')"
  default     = ""
  sensitive   = true
}

variable "enable_ipv6" {
  type        = bool
  description = "Whether IPv6 (dual-stack) is enabled — used for existing-VPC validation."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "(Optional) VPC ID to validate — checked for whitespace and the vpc_id/vpc_name pairing."
  default     = ""
}

variable "vpc_name" {
  type        = string
  description = "(Optional) New-VPC name to validate. null means the module has no vpc_name concept (skips the vpc_id-or-vpc_name pairing check)"
  default     = null
}

variable "vswitch_id" {
  type        = string
  description = "(Optional) vSwitch ID to validate — empty allowed, blank/whitespace rejected"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "(Optional) ECS key pair name to validate — empty allowed, blank/whitespace rejected"
  default     = ""
}

variable "ram_role_name" {
  type        = string
  description = "(Optional) RAM role name to validate — empty allowed, blank/whitespace rejected"
  default     = ""
}

variable "bootstrap_script" {
  type        = string
  description = "(Optional) Bootstrap script to validate — empty allowed, blank (whitespace-only) rejected"
  default     = ""
}

variable "ipv6_gateway_id" {
  type        = string
  description = "(Optional) Existing IPv6 gateway ID — required when dual-stack + existing VPC."
  default     = ""
}

variable "ipv6_internet_bandwidth" {
  type        = number
  description = "(Optional) IPv6 internet bandwidth in Mbps — validated when enable_ipv6 is true. 0 = VPC-internal IPv6 only (no public IPv6)."
  default     = 100
}

variable "ipv6_internet_charge_type" {
  type        = string
  description = "(Optional) IPv6 internet billing model. Allowed: PayByBandwidth, PayByTraffic. Also bounds the accepted ipv6_internet_bandwidth range."
  default     = "PayByTraffic"

  validation {
    condition     = contains(["PayByBandwidth", "PayByTraffic"], var.ipv6_internet_charge_type)
    error_message = "ipv6_internet_charge_type must be one of: PayByBandwidth, PayByTraffic."
  }
}

variable "admin_cidr_ipv6" {
  type        = string
  description = "(Optional) Management admin IPv6 CIDR — required and format-checked when enable_ipv6 is true and chkp_type is management."
  default     = ""
}

variable "gateway_addresses_ipv6" {
  type        = string
  description = "(Optional) Management gateway-source IPv6 CIDR — required and format-checked when enable_ipv6 is true and chkp_type is management."
  default     = ""
}
