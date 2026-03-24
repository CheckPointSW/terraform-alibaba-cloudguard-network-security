variable "gateway_name" {
  type        = string
  description = "Name tag of the Security Gateway instance"
  default     = "Check-Point-Gateway-tf"
}

variable "vswitch_id" {
  type        = string
  description = "The public vSwitch ID to deploy the gateway instance into"
}

variable "volume_size" {
  type        = number
  description = "Root volume size (GB)"
  default     = 100
}

variable "disk_category" {
  type        = string
  description = "(Optional) ECS disk category"
  default     = "cloud_efficiency"
}

variable "gateway_version" {
  type        = string
  description = "Gateway version and license"
  default     = "R81.20-BYOL"
}

variable "gateway_instance_type" {
  type        = string
  description = "The instance type of the Security Gateway"
  default     = "ecs.g5ne.xlarge"
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Tags to add to the Gateway ECS instance"
  default     = {}
}

variable "key_name" {
  type        = string
  description = "ECS Key Pair name to allow SSH access to the instance"
}

variable "image_id" {
  type        = string
  description = "The image ID to use for the instance"
}

variable "security_groups" {
  type        = list(string)
  description = "Security group IDs to attach to the instance"
}

variable "gateway_password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash (use 'openssl passwd -6 PASSWORD')"
  default     = ""
}

variable "admin_shell" {
  type        = string
  description = "Admin shell for advanced command line configuration"
  default     = "/etc/cli.sh"
}

variable "gateway_SICKey" {
  type        = string
  description = "Secure Internal Communication key (at least 8 alphanumeric characters)"
}

variable "gateway_TokenKey" {
  type        = string
  description = "Smart-1 Cloud token (see SK180501)"
  default     = ""
}

variable "gateway_bootstrap_script" {
  type        = string
  description = "(Optional) Semicolon-separated commands to run on initial boot"
  default     = ""
}

variable "gateway_hostname" {
  type        = string
  description = "(Optional) Hostname for the gateway"
  default     = ""
}

variable "allow_upload_download" {
  type        = bool
  description = "Automatically download Blade Contracts and improve product experience"
  default     = true
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

variable "private_vswitch_id" {
  type        = string
  description = "The private vSwitch ID for the internal ENI (eth1)"
}

variable "eni_name_prefix" {
  type        = string
  description = "Name prefix for the internal ENI resource"
}
