variable "prefix" {
  type        = string
  description = "Name prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "Resolved VPC ID"
}

variable "vswitches" {
  type = map(object({
    id      = string
    zone_id = string
  }))
  description = "Resolved map of zone → {id, zone_id}"
}

variable "image_id" {
  type        = string
  description = "Check Point gateway image ID"
}

variable "sg_id" {
  type        = string
  description = "Permissive security group ID"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "gateway_instance_type" {
  type        = string
  description = "ECS instance type"
}

variable "gateway_version" {
  type        = string
  description = "Check Point version and license"
}

variable "gateway_SICKey" {
  type        = string
  sensitive   = true
  description = "SIC key"
}

variable "gateway_password_hash" {
  type        = string
  sensitive   = true
  description = "Admin password hash"
}

variable "gateway_bootstrap_script" {
  type        = string
  sensitive   = true
  description = "Bootstrap script"
}

variable "admin_shell" {
  type        = string
  description = "Admin shell"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
}

variable "disk_category" {
  type        = string
  description = "ECS disk category"
}

variable "allocate_public_ip" {
  type        = bool
  description = "Assign a public IP to each NVA instance"
}

variable "gateway_internet_charge_type" {
  type        = string
  description = "Billing method for public IP traffic (PayByTraffic or PayByBandwidth)"
}

variable "gateway_internet_max_bandwidth_out" {
  type        = number
  description = "Outbound public bandwidth in Mbit/s"
}

variable "min_group_size" {
  type        = number
  description = "Minimum number of NVA instances"
}

variable "max_group_size" {
  type        = number
  description = "Maximum number of NVA instances"
}

variable "desired_capacity" {
  type        = number
  description = "Initial number of NVA instances"
}

variable "cpu_usage" {
  type        = number
  description = "Target CPU utilization % for auto-scaling"
}

variable "multi_az_policy" {
  type        = string
  description = "ESS multi-zone distribution policy"
}

variable "connection_drain_timeout" {
  type        = number
  description = "Seconds to drain connections on scale-in"
}

variable "management_name" {
  type        = string
  description = "CME management server name"
}

variable "configuration_template_name" {
  type        = string
  description = "CME configuration template name"
}

variable "allow_upload_download" {
  type        = bool
  description = "Allow Blade Contract and telemetry download"
}

variable "primary_ntp" {
  type        = string
  description = "Primary NTP server"
}

variable "secondary_ntp" {
  type        = string
  description = "Secondary NTP server"
}

variable "instance_tags" {
  type        = map(string)
  description = "Additional tags for NVA instances"
}
