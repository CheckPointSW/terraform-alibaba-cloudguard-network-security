// --- Instance type validation ---
locals {
  gw_types = [
    "ecs.g5ne.large",
    "ecs.g5ne.xlarge",
    "ecs.g5ne.2xlarge",
    "ecs.g5ne.4xlarge",
    "ecs.g5ne.8xlarge",
    "ecs.g7ne.large",
    "ecs.g7ne.xlarge",
    "ecs.g7ne.2xlarge",
    "ecs.g7ne.4xlarge",
    "ecs.g7ne.8xlarge"
  ]
  mgmt_types = [
    "ecs.g6e.large",
    "ecs.g6e.xlarge",
    "ecs.g6e.2xlarge",
    "ecs.g6e.4xlarge",
    "ecs.g6e.8xlarge",
    "ecs.g7.large",
    "ecs.g7.xlarge",
    "ecs.g7.2xlarge",
    "ecs.g7.4xlarge",
    "ecs.g7.8xlarge",
  ]
  allowed_instance_types = coalescelist(
    var.chkp_type == "gateway" ? local.gw_types : [],
    var.chkp_type == "management" ? local.mgmt_types : []
  )
  // Will fail at plan time if var.instance_type is not in the allowed list
  validate_instance_type = index(local.allowed_instance_types, var.instance_type)
}

// --- Version/license validation ---
locals {
  gw_versions = [
    "R81.10-BYOL",
    "R81.20-BYOL",
    "R82-BYOL",
    "R82.10-BYOL"
  ]
  mgmt_versions = [
    "R81.10-BYOL",
    "R81.20-BYOL",
    "R82-BYOL",
    "R82.10-BYOL"
  ]
  allowed_versions = coalescelist(
    var.chkp_type == "gateway" ? local.gw_versions : [],
    var.chkp_type == "management" ? local.mgmt_versions : []
  )
  // Will fail at plan time if var.version_license is not in the allowed list
  validate_version_license = index(local.allowed_versions, var.version_license)
}

// --- Volume size validation ---
resource "null_resource" "volume_size_too_small" {
  // Will fail if volume_size is less than 100
  count = var.volume_size >= 100 ? 0 : "volume_size must be at least 100"
}

// --- Admin shell validation ---
locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"
  ]
  // Will fail if var.admin_shell is not in the allowed list
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)
}

// --- Hostname validation ---
locals {
  regex_valid_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
  // Will fail if var.hostname is not a valid hostname label or empty string
  validate_hostname = regex(local.regex_valid_hostname, var.hostname) == var.hostname ? 0 : "Variable [hostname] must be a valid hostname label or an empty string"
}

// --- SIC key validation (skipped if empty) ---
locals {
  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.sic_key is non-empty and invalid
  validate_sic_key = var.sic_key != "" ? (
    regex(local.regex_valid_sic_key, var.sic_key) == var.sic_key ? 0 : "Variable [sic_key] must be at least 8 alphanumeric characters"
  ) : 0
}

// --- Smart-1 Cloud token validation (skipped if empty) ---
locals {
  split_token      = split(" ", var.token)
  token_decode     = var.token != "" ? base64decode(element(local.split_token, length(local.split_token) - 1)) : ""
  regex_token_valid = "(^https://(.+).checkpoint.com/app/maas/api/v1/tenant(.+)|^$)"
  // Will fail if var.token is non-empty and contains an invalid Smart-1 Cloud URL
  validate_token = var.token != "" ? (
    regex(local.regex_token_valid, local.token_decode) == local.token_decode ? 0 : "Smart-1 Cloud token is invalid format"
  ) : 0
}
