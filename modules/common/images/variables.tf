variable "chkp_type" {
  type        = string
  description = "The Check Point machine type"
  default     = "gateway"
}

variable "version_license" {
  type        = string
  description = "Version and license"
  default     = "R81.20-BYOL"
}
