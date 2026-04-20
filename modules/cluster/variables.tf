// ─── Option A: Deploy into an existing VPC ───────────────────────────────────
variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC. Leave empty to create a new VPC instead."
  default     = ""
}

variable "cluster_vswitch_id" {
  type        = string
  description = "Existing cluster (public) vSwitch ID for member instances. Required when deploying into an existing VPC."
  default     = ""
}

variable "mgmt_vswitch_id" {
  type        = string
  description = "Existing management vSwitch ID for management ENIs. Required when deploying into an existing VPC."
  default     = ""
}

variable "private_vswitch_id" {
  type        = string
  description = "Existing private vSwitch ID for internal ENIs. Required when deploying into an existing VPC."
  default     = ""
}

variable "private_route_table" {
  type        = string
  description = "(Optional) Existing private route table ID. If set, adds 0.0.0.0/0 route via the active member's internal ENI."
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

variable "cluster_vswitchs_map" {
  type        = map(string)
  description = "Map of {availability-zone = vswitch-suffix-number} for cluster (public) vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 1})"
  default     = {}
}

variable "management_vswitchs_map" {
  type        = map(string)
  description = "Map of {availability-zone = vswitch-suffix-number} for management vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 2})"
  default     = {}
}

variable "private_vswitchs_map" {
  type        = map(string)
  description = "Map of {availability-zone = vswitch-suffix-number} for private vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 3})"
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
  description = "(Optional) Name tag prefix for the cluster member instances"
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

variable "allocate_and_associate_eip" {
  type        = bool
  description = "If true, allocates and associates an Elastic IP with each member's management ENI (in addition to the cluster EIP)"
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
  description = "(Optional) Predefined RAM role name. If empty, a new RAM role will be created automatically."
  default     = ""
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to the cluster member instances"
  default     = {}
}

// ─── Check Point Settings ─────────────────────────────────────────────────────
variable "gateway_version" {
  type        = string
  description = "Gateway version and license"
  default     = "R81.20-BYOL"
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
variable "memberAToken" {
  type        = string
  description = "Smart-1 Cloud token for Member A (see SK180501). Must differ from memberBToken."
  default     = ""
  sensitive   = true
}

variable "memberBToken" {
  type        = string
  description = "Smart-1 Cloud token for Member B (see SK180501). Must differ from memberAToken."
  default     = ""
  sensitive   = true
}

// ─── Advanced Settings ────────────────────────────────────────────────────────
variable "management_ip_address" {
  type        = string
  description = "(Optional) Management server IP — adds a static route via eth1 to this address on both members"
  default     = ""
}

variable "resources_tag_name" {
  type        = string
  description = "(Optional) Name tag prefix for resources"
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
