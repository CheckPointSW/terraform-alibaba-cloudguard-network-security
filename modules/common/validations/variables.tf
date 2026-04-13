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
  default     = 100
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
