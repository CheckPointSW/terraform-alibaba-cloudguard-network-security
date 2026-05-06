variable "vpc_id" {
  type        = string
  description = "The VPC ID in which to create the management security group"
}

variable "vswitch_id" {
  type        = string
  description = "The vSwitch ID to deploy the management instance into"
}

variable "instance_name" {
  type        = string
  description = "Name for the management server ECS instance"
  default     = "CP-Management-tf"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the management server"
  default     = "ecs.g7.xlarge"
}

variable "key_name" {
  type        = string
  description = "ECS Key Pair name to allow SSH access to the instance"
}

variable "volume_size" {
  type        = number
  description = "Root volume size (GB)"
  default     = 200
}

variable "disk_category" {
  type        = string
  description = "(Optional) ECS disk category"
  default     = "cloud_essd"
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to the management instance"
  default     = {}
}

variable "image_id" {
  type        = string
  description = "The image ID to use for the management instance"
}

variable "version_license" {
  type        = string
  description = "Version and license (used for OsVersion in userdata)"
  default     = "R81.20-BYOL"
}

variable "admin_shell" {
  type        = string
  description = "Admin shell for advanced command line configuration"
  default     = "/etc/cli.sh"
}

variable "password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash (use 'openssl passwd -6 PASSWORD')"
  default     = ""
}

variable "hostname" {
  type        = string
  description = "(Optional) Hostname for the management server"
  default     = ""
}

variable "is_primary_management" {
  type        = bool
  description = "true = primary management server, false = secondary"
  default     = true
}

variable "SICKey" {
  type        = string
  description = "SIC key — mandatory only for secondary management servers"
  default     = ""
}

variable "allow_upload_download" {
  type        = bool
  description = "Automatically download Blade Contracts and improve product experience"
  default     = true
}

variable "gateway_management" {
  type        = string
  description = "Select 'Over the internet' if gateways are accessed via public IPs, otherwise 'Locally managed'"
  default     = "Locally managed"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR to allow web, SSH, and graphical client access to the management server"
}

variable "gateway_addresses" {
  type        = string
  description = "CIDR to allow gateway communication with the management server"
}

variable "primary_ntp" {
  type        = string
  description = "(Optional) Primary NTP server IPv4 address"
  default     = "ntp.cloud.aliyuncs.com"
}

variable "secondary_ntp" {
  type        = string
  description = "(Optional) Secondary NTP server IPv4 address"
  default     = "ntp7.cloud.aliyuncs.com"
}

variable "bootstrap_script" {
  type        = string
  description = "(Optional) Semicolon-separated commands to run on initial boot"
  default     = ""
}

variable "allocate_and_associate_eip" {
  type        = bool
  description = "Passed to userdata so the management server knows whether it has a public IP"
  default     = true
}
