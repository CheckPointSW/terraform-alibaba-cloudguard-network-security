variable "gateway_name" {
  type        = string
  description = "Name tag prefix for the cluster member instances"
  default     = "Check-Point-Cluster-tf"
}

variable "gateway_instance_type" {
  type        = string
  description = "Instance type for the cluster members"
  default     = "ecs.g5ne.xlarge"
}

variable "key_name" {
  type        = string
  description = "ECS Key Pair name to allow SSH access to the instances"
}

variable "image_id" {
  type        = string
  description = "The image ID to use for both cluster member instances"
}

variable "permissive_sg_id" {
  type        = string
  description = "ID of the permissive security group to attach to instances and ENIs"
}

variable "cluster_vswitch_id" {
  type        = string
  description = "The cluster (public) vSwitch ID for the member instances (eth0)"
}

variable "mgmt_vswitch_id" {
  type        = string
  description = "The management vSwitch ID for the management ENIs (eth2)"
}

variable "private_vswitch_id" {
  type        = string
  description = "The private vSwitch ID for the internal ENIs (eth1)"
}

variable "volume_size" {
  type        = number
  description = "Root volume size (GB)"
  default     = 200
}

variable "disk_category" {
  type        = string
  description = "(Optional) ECS disk category"
  default     = "cloud_efficiency"
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to the cluster member instances"
  default     = {}
}

variable "resources_tag_name" {
  type        = string
  description = "(Optional) Name tag prefix for ENI resources"
  default     = ""
}

variable "gateway_version" {
  type        = string
  description = "Gateway version and license (used for OsVersion in userdata)"
  default     = "R82-BYOL"
}

variable "admin_shell" {
  type        = string
  description = "Admin shell for advanced command line configuration"
  default     = "/etc/cli.sh"
}

variable "gateway_SICKey" {
  type        = string
  description = "Secure Internal Communication key"
}

variable "gateway_password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash"
  default     = ""
}

variable "memberAToken" {
  type        = string
  description = "Smart-1 Cloud token for Member A"
  default     = ""
}

variable "memberBToken" {
  type        = string
  description = "Smart-1 Cloud token for Member B"
  default     = ""
}

variable "gateway_bootstrap_script" {
  type        = string
  description = "(Optional) Semicolon-separated commands to run on initial boot"
  default     = ""
}

variable "gateway_hostname" {
  type        = string
  description = "(Optional) Hostname prefix — appended with -member-a/-member-b"
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

variable "management_ip_address" {
  type        = string
  description = "(Optional) Management server IP — adds a static route via eth1 to this address"
  default     = ""
}
