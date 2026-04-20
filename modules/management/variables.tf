// ─── Option A: Deploy into an existing VPC ───────────────────────────────────
variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC. Leave empty to create a new VPC instead."
  default     = ""
}

variable "vswitch_id" {
  type        = string
  description = "Existing vSwitch ID to deploy the management server into. Required when deploying into an existing VPC."
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
  description = "Map of {availability-zone = vswitch-suffix-number} for vSwitches. Used only when vpc_id is empty. (e.g. {\"us-east-1a\" = 1})"
  default     = {}
}

variable "vswitchs_bit_length" {
  type        = number
  description = "Number of bits to extend the vpc_cidr per vSwitch subnet. (e.g. /16 + 8 = /24)"
  default     = 8
}

// ─── ECS Instance Configuration ──────────────────────────────────────────────
variable "instance_name" {
  type        = string
  description = "Name for the management server ECS instance"
  default     = "CP-Management-tf"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the management server"
  default     = "ecs.g6e.xlarge"
}

variable "key_name" {
  type        = string
  description = "ECS Key Pair name to allow SSH access to the instance"
}

variable "allocate_and_associate_eip" {
  type        = bool
  description = "If true, allocates and associates an Elastic IP with the management instance"
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
  default     = "cloud_essd"
}

variable "ram_role_name" {
  type        = string
  description = "(Optional) RAM role name to attach to the instance"
  default     = ""
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to the management instance"
  default     = {}
}

// ─── Check Point Settings ─────────────────────────────────────────────────────
variable "version_license" {
  type        = string
  description = "Management server version and license"
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
  sensitive   = true
}

variable "hostname" {
  type        = string
  description = "(Optional) Hostname for the management server"
  default     = ""
}

// ─── Management Server Settings ───────────────────────────────────────────────
variable "is_primary_management" {
  type        = bool
  description = "true = primary management server, false = secondary"
  default     = true
}

variable "SICKey" {
  type        = string
  description = "SIC key — mandatory only when deploying a secondary management server"
  default     = ""
  sensitive   = true
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

// ─── Advanced Settings ────────────────────────────────────────────────────────
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
