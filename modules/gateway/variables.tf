// ─── Option A: Deploy into an existing VPC ───────────────────────────────────
variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC. Leave empty to create a new VPC instead."
  default     = ""
}

variable "public_vswitch_id" {
  type        = string
  description = "Existing public vSwitch ID. Required when deploying into an existing VPC."
  default     = ""
}

variable "private_vswitch_id" {
  type        = string
  description = "Existing private vSwitch ID. Required when deploying into an existing VPC."
  default     = ""
}

variable "private_route_table" {
  type        = string
  description = "(Optional) Existing private route table ID. If set, adds 0.0.0.0/0 route via the gateway's internal ENI. Route table must not already have a 0.0.0.0/0 entry."
  default     = ""
}

// ─── Option B: Create a new VPC ──────────────────────────────────────────────
variable "vpc_name" {
  type        = string
  description = "Name for the new VPC. Used only when vpc_id is empty."
  default     = "cp-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the new VPC."
  default     = "10.0.0.0/16"
}

variable "public_vswitchs_map" {
  type        = map(string)
  description = "Map of {availability-zone = vswitch-suffix-number} for public vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 1})"
  default     = {}
}

variable "private_vswitchs_map" {
  type        = map(string)
  description = "Map of {availability-zone = vswitch-suffix-number} for private vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 2})"
  default     = {}
}

variable "vswitchs_bit_length" {
  type        = number
  description = "Number of bits to extend the vpc_cidr per vSwitch subnet. (e.g. /16 + 8 = /24)"
  default     = 8
}

// ─── ECS Instance Configuration ──────────────────────────────────────────────
variable "gateway_name" {
  type        = string
  description = "(Optional) Name tag for the Security Gateway instance"
  default     = "Check-Point-Gateway-tf"
}

variable "gateway_instance_type" {
  type        = string
  description = "Instance type for the Security Gateway"
  default     = "ecs.g5ne.xlarge"
}

variable "key_name" {
  type        = string
  description = "ECS Key Pair name to allow SSH access to the instance"
}

variable "allocate_and_associate_eip" {
  type        = bool
  description = "If true, allocates and associates an Elastic IP with the instance"
  default     = true
}

variable "volume_size" {
  type        = number
  description = "Root volume size (GB) — minimum 100"
  default     = 200
}

variable "disk_category" {
  type        = string
  description = "(Optional) ECS disk category"
  default     = "cloud_efficiency"
}

variable "ram_role_name" {
  type        = string
  description = "(Optional) RAM role name to attach to the instance"
  default     = ""
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to the Gateway ECS instance"
  default     = {}
}

// ─── Check Point Settings ─────────────────────────────────────────────────────
variable "gateway_version" {
  type        = string
  description = "Gateway version and license"
  default     = "R82-BYOL"
}

variable "admin_shell" {
  type        = string
  description = "Admin shell for advanced command line configuration"
  default     = "/etc/cli.sh"
}

variable "gateway_SICKey" {
  type        = string
  description = "Secure Internal Communication key (at least 8 alphanumeric characters)"
  sensitive   = true
}

variable "gateway_password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash (use 'openssl passwd -6 PASSWORD')"
  default     = ""
  sensitive   = true
}

// ─── Smart-1 Cloud ────────────────────────────────────────────────────────────
variable "gateway_TokenKey" {
  type        = string
  description = "(Optional) Smart-1 Cloud token to quickly connect to Smart-1 Cloud (see SK180501)"
  default     = ""
  sensitive   = true
}

// ─── Advanced Settings ────────────────────────────────────────────────────────
variable "resources_tag_name" {
  type        = string
  description = "(Optional) Name tag prefix for resources"
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

variable "gateway_bootstrap_script" {
  type        = string
  description = "(Optional) Semicolon-separated commands to run on initial boot"
  default     = ""
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

// ─── IPv6 / Dual-Stack ──────────────────────────────────────────────────────
variable "enable_ipv6" {
  type        = bool
  description = "Enable IPv6 (dual-stack) for the gateway deployment."
  default     = false
}

variable "ipv6_gateway_id" {
  type        = string
  description = "(Optional) Existing IPv6 gateway ID. Required when enable_ipv6 = true, deploying into an existing VPC, AND ipv6_internet_bandwidth > 0. Not required for internal-only IPv6 (bandwidth = 0)."
  default     = ""
}

variable "ipv6_internet_bandwidth" {
  type        = number
  description = "IPv6 internet bandwidth in Mbps (0-5000). Only used when enable_ipv6 = true. Set to 0 to skip the IPv6 gateway + bandwidth and keep IPv6 VPC-internal only (no public IPv6)."
  default     = 100
}

variable "ipv6_internet_charge_type" {
  type        = string
  description = "Billing model for the IPv6 internet bandwidth. PayByTraffic = pay per GB transferred; PayByBandwidth = flat fee per reserved Mbps. Only used when enable_ipv6 = true and ipv6_internet_bandwidth > 0."
  default     = "PayByTraffic"
}
