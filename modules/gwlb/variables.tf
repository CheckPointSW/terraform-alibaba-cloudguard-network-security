// --- General ---

variable "prefix" {
  type        = string
  description = "Name prefix for all resources. Controls naming as prefix-<resource>. e.g. 'cp-gwlb' → cp-gwlb-security-vpc, cp-gwlb-server-group, cp-gwlb-gw-001..."
}

// --- Security VPC ---

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC to deploy into. Leave empty to create a new security VPC."
  default     = ""
}

variable "security_vpc_cidr" {
  type        = string
  description = "CIDR block for the security VPC"
  default     = "10.0.0.0/16"
}

variable "security_vswitchs_map" {
  type        = map(number)
  description = "Map of {availability-zone = vswitch-cidr-suffix} for creating new vSwitches. Used when vpc_id is empty. e.g. {\"cn-hangzhou-j\" = 1, \"cn-hangzhou-k\" = 2}. NOTE: only zones that support GWLB are valid — verify in the Alibaba console before adding a zone. Zones can be added post-deploy but CANNOT be removed (Alibaba API restriction)."
  default     = {}
}

variable "security_vswitchs_ids" {
  type        = list(string)
  description = "List of existing vSwitch IDs. Used when vpc_id is set. e.g. [\"vsw-bp1xxx\", \"vsw-bp1yyy\"]. The module looks up each vSwitch's zone automatically."
  default     = []
}

variable "vswitchs_bit_length" {
  type        = number
  description = "Number of bits to extend the security_vpc_cidr per vSwitch subnet (e.g. /16 + 8 = /24)"
  default     = 8
}

// --- Check Point NVA Scale Set ---

variable "allocate_public_ip" {
  type        = bool
  description = "(Optional) Assign a public IP to each NVA instance. Set to false when management is via private network only."
  default     = true
}

variable "gateway_internet_charge_type" {
  type        = string
  description = "(Optional) Billing method for public IP traffic. PayByTraffic charges per GB transferred; PayByBandwidth charges for a fixed bandwidth cap."
  default     = "PayByTraffic"

  validation {
    condition     = contains(["PayByTraffic", "PayByBandwidth"], var.gateway_internet_charge_type)
    error_message = "gateway_internet_charge_type must be PayByTraffic or PayByBandwidth."
  }
}

variable "gateway_internet_max_bandwidth_out" {
  type        = number
  description = "Outbound public bandwidth in Mbit/s (1–100, default 100). Only used when allocate_public_ip is true."
  default     = 100

  validation {
    condition     = var.gateway_internet_max_bandwidth_out >= 1 && var.gateway_internet_max_bandwidth_out <= 100
    error_message = "gateway_internet_max_bandwidth_out must be between 1 and 100 Mbit/s."
  }
}

variable "gateway_instance_type" {
  type        = string
  description = "ECS instance type for the Check Point gateway (g5ne or g7ne family)"
  default     = "ecs.g5ne.xlarge"

}

variable "key_name" {
  type        = string
  description = "SSH key pair name for instance access"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB (minimum 100)"
  default     = 200

}

variable "disk_category" {
  type        = string
  description = "ECS disk category"
  default     = "cloud_efficiency"
}

variable "gateway_version" {
  type        = string
  description = "Check Point gateway version and license (e.g. R82.20-BYOL)"
  default     = "R82-BYOL"

  validation {
    condition = contains([
      "R81.20-BYOL",
      "R82-BYOL", "R82.10-BYOL",
    ], var.gateway_version)
    error_message = "gateway_version must be R81.20-BYOL or newer. R81 and R81.10 are not supported for GWLB."
  }
}

variable "gateway_SICKey" {
  type        = string
  description = "Secure Internal Communication key (at least 8 alphanumeric characters)"
  sensitive   = true

}

variable "gateway_password_hash" {
  type        = string
  description = "(Optional) Admin user's password hash"
  sensitive   = true
  default     = ""
}

variable "admin_shell" {
  type        = string
  description = "Admin shell for the gateway"
  default     = "/etc/cli.sh"

}

variable "gateway_bootstrap_script" {
  type        = string
  description = "(Optional) Semicolon-separated bootstrap commands"
  sensitive   = true
  default     = ""
}

variable "allow_upload_download" {
  type        = bool
  description = "Allow software blade contract download"
  default     = true
}

variable "connection_drain_timeout" {
  type        = number
  description = "Seconds to wait for in-flight connections to complete before removing an instance from the GWLB server group. Connection draining is always enabled."
  default     = 300

  validation {
    condition     = var.connection_drain_timeout >= 1 && var.connection_drain_timeout <= 3600
    error_message = "connection_drain_timeout must be between 1 and 3600 seconds."
  }
}

variable "multi_az_policy" {
  type        = string
  description = "ESS multi-zone instance distribution policy. Default BALANCE spreads instances evenly across zones."
  default     = "BALANCE"

  validation {
    condition     = contains(["PRIORITY", "BALANCE"], var.multi_az_policy)
    error_message = "multi_az_policy must be one of: PRIORITY, BALANCE."
  }
}

// --- Scale Set Sizing ---

variable "min_group_size" {
  type        = number
  description = "Minimum number of instances in the scaling group"
  default     = 2

  validation {
    condition     = var.min_group_size >= 1
    error_message = "min_group_size must be at least 1."
  }
}

variable "max_group_size" {
  type        = number
  description = "Maximum number of instances in the scaling group"
  default     = 10

  validation {
    condition     = var.max_group_size >= 1
    error_message = "max_group_size must be at least 1."
  }
}

variable "desired_capacity" {
  type        = number
  description = "Initial number of instances in the scaling group (must be between min_group_size and max_group_size)"
  default     = 2

  validation {
    condition     = var.desired_capacity >= 1
    error_message = "desired_capacity must be at least 1."
  }
}

variable "cpu_usage" {
  type        = number
  description = "Target CPU utilization percentage for auto-scaling"
  default     = 60

  validation {
    condition     = var.cpu_usage >= 1 && var.cpu_usage <= 100
    error_message = "cpu_usage must be between 1 and 100."
  }
}

// --- CME Auto-Provisioning ---

variable "management_name" {
  type        = string
  description = "CME management server name for auto-provisioning"
  default     = "mgmt"
}

variable "configuration_template_name" {
  type        = string
  description = "CME configuration template name for auto-provisioning"
  default     = "template"
}

// --- Common ---

variable "primary_ntp" {
  type        = string
  description = "Primary NTP server"
  default     = "ntp.cloud.aliyuncs.com"
}

variable "secondary_ntp" {
  type        = string
  description = "Secondary NTP server"
  default     = "ntp7.cloud.aliyuncs.com"
}

variable "instance_tags" {
  type        = map(string)
  description = "(Optional) Additional tags for instances"
  default     = {}
}
