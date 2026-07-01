// Checks use the null_resource count-string trick (fails plan when count is a
// string); a resource arg is always evaluated, so unlike a bare local it fires.

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
}

resource "null_resource" "invalid_instance_type" {
  count = contains(local.allowed_instance_types, var.instance_type) ? 0 : "instance_type '${var.instance_type}' is not supported for chkp_type '${var.chkp_type}'. Supported values: ${join(", ", local.allowed_instance_types)}"
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
}

resource "null_resource" "invalid_version_license" {
  count = contains(local.allowed_versions, var.version_license) ? 0 : "version_license '${var.version_license}' is not supported for chkp_type '${var.chkp_type}'. Supported values: ${join(", ", local.allowed_versions)}"
}

// --- Volume size validation ---
resource "null_resource" "volume_size_too_small" {
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
}

resource "null_resource" "invalid_admin_shell" {
  count = contains(local.admin_shell_allowed_values, var.admin_shell) ? 0 : "admin_shell '${var.admin_shell}' is not supported. Supported values: ${join(", ", local.admin_shell_allowed_values)}"
}

// --- Hostname validation (empty allowed) ---
locals {
  regex_valid_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
}

resource "null_resource" "invalid_hostname" {
  count = length(regexall(local.regex_valid_hostname, var.hostname)) > 0 ? 0 : "hostname '${var.hostname}' must be 1-63 chars, start with a letter, contain only letters/digits/hyphen, and end alphanumeric — or an empty string"
}

// --- SIC key validation (skipped if empty) ---
locals {
  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
}

resource "null_resource" "invalid_sic_key" {
  count = var.sic_key == "" || length(regexall(local.regex_valid_sic_key, var.sic_key)) > 0 ? 0 : "sic_key must be at least 8 alphanumeric characters"
}

// --- Smart-1 Cloud token validation (skipped if empty) ---
locals {
  split_token      = split(" ", var.token)
  token_decode     = var.token != "" ? base64decode(element(local.split_token, length(local.split_token) - 1)) : ""
  regex_token_valid = "(^https://(.+).checkpoint.com/app/maas/api/v1/tenant(.+)|^$)"
}

resource "null_resource" "invalid_token" {
  count = var.token == "" || length(regexall(local.regex_token_valid, local.token_decode)) > 0 ? 0 : "Smart-1 Cloud token is invalid format"
}

// --- Password hash validation (empty allowed; reject blank/whitespace) ---
resource "null_resource" "invalid_password_hash" {
  count = var.password_hash == "" || trimspace(var.password_hash) == var.password_hash ? 0 : "password_hash must be empty or a non-blank value with no leading/trailing whitespace"
}

// --- VPC identity validation ---
resource "null_resource" "invalid_vpc_id_whitespace" {
  count = trimspace(var.vpc_id) == var.vpc_id ? 0 : "vpc_id must not contain leading/trailing whitespace (use \"\" to create a new VPC)"
}

resource "null_resource" "invalid_vpc_name_whitespace" {
  count = var.vpc_name == null || trimspace(var.vpc_name) == var.vpc_name ? 0 : "vpc_name must not contain leading/trailing whitespace"
}

// Modules that have a vpc_name require either an existing vpc_id or a new-VPC name.
resource "null_resource" "vpc_id_or_name_required" {
  count = var.vpc_name == null ? 0 : (trimspace(var.vpc_id) != "" || trimspace(var.vpc_name) != "" ? 0 : "Either vpc_id (deploy into an existing VPC) or vpc_name (create a new VPC) must be set — both cannot be empty")
}

// --- Whitespace-only / blank optional string inputs (empty allowed) ---
resource "null_resource" "invalid_vswitch_id" {
  count = var.vswitch_id == "" || trimspace(var.vswitch_id) == var.vswitch_id ? 0 : "vswitch_id must not be blank or contain leading/trailing whitespace"
}

resource "null_resource" "invalid_key_name" {
  count = var.key_name == "" || trimspace(var.key_name) == var.key_name ? 0 : "key_name must not be blank or contain leading/trailing whitespace"
}

resource "null_resource" "invalid_ram_role_name" {
  count = var.ram_role_name == "" || trimspace(var.ram_role_name) == var.ram_role_name ? 0 : "ram_role_name must not be blank or contain leading/trailing whitespace"
}

resource "null_resource" "invalid_bootstrap_script" {
  count = var.bootstrap_script == "" || trimspace(var.bootstrap_script) == var.bootstrap_script ? 0 : "bootstrap_script must not be blank or contain leading/trailing whitespace"
}
