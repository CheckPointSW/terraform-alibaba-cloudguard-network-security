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
    "R81.20-BYOL",
    "R82-BYOL",
    "R82.10-BYOL",
    "R82.20-BYOL"
  ]
  mgmt_versions = [
    "R81.20-BYOL",
    "R82-BYOL",
    "R82.10-BYOL",
    "R82.20-BYOL"
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
  split_token       = split(" ", var.token)
  token_decode      = var.token != "" ? base64decode(element(local.split_token, length(local.split_token) - 1)) : ""
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
  count = var.bootstrap_script == "" || trimspace(var.bootstrap_script) != "" ? 0 : "bootstrap_script must not be blank (whitespace only)"
}

// --- Dual-stack + existing VPC + public IPv6 requires ipv6_gateway_id ---
// When ipv6_internet_bandwidth = 0 (VPC-internal IPv6 only), the IPv6 gateway is
// not consumed by anything, so it isn't required.
locals {
  needs_existing_ipv6_gateway = var.enable_ipv6 && var.vpc_id != "" && var.ipv6_internet_bandwidth > 0
  validate_ipv6_gateway_id = regex("^$", (
    local.needs_existing_ipv6_gateway && var.ipv6_gateway_id == ""
    ? "ipv6_gateway_id is required when deploying dual-stack into an existing VPC with public IPv6 (ipv6_internet_bandwidth > 0)"
    : ""
  ))
}

// --- IPv6 internet bandwidth validation (skipped if IPv6 is disabled) ---
// 0 = no public IPv6 (skip IPv6 gateway + bandwidth, instance keeps VPC-internal IPv6 only).
// Max Mbps is charge-type dependent, per Alibaba AllocateIpv6InternetBandwidth:
// PayByBandwidth up to 2000, PayByTraffic up to 1000.
locals {
  ipv6_bandwidth_max = var.ipv6_internet_charge_type == "PayByBandwidth" ? 2000 : 1000
  validate_ipv6_bandwidth = var.enable_ipv6 ? regex("^$", (
    var.ipv6_internet_bandwidth < 0 || var.ipv6_internet_bandwidth > local.ipv6_bandwidth_max
    ? "ipv6_internet_bandwidth must be between 0 and ${local.ipv6_bandwidth_max} Mbps for ipv6_internet_charge_type '${var.ipv6_internet_charge_type}' (0 = no public IPv6)"
    : ""
  )) : ""
}

// --- Management dual-stack admin/gateway IPv6 CIDR validation ---
// Required when enable_ipv6 = true on the management module; format-checked when non-empty.
locals {
  // Permissive IPv6 CIDR regex — accepts standard hex IPv6 with optional :: compression and /0-128 prefix.
  regex_valid_ipv6_cidr = "^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}(:[0-9a-fA-F]{1,4}){1,1}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))(/(12[0-8]|1[01][0-9]|[1-9]?[0-9]))$"
  mgmt_dual_stack       = var.enable_ipv6 && var.chkp_type == "management"

  validate_admin_cidr_ipv6_required = regex("^$", (
    local.mgmt_dual_stack && var.admin_cidr_ipv6 == ""
    ? "admin_cidr_ipv6 is required when enable_ipv6 = true on the management module"
    : ""
  ))
  validate_gateway_addresses_ipv6_required = regex("^$", (
    local.mgmt_dual_stack && var.gateway_addresses_ipv6 == ""
    ? "gateway_addresses_ipv6 is required when enable_ipv6 = true on the management module"
    : ""
  ))
  validate_admin_cidr_ipv6_format = var.admin_cidr_ipv6 != "" ? (
    regex(local.regex_valid_ipv6_cidr, var.admin_cidr_ipv6) == var.admin_cidr_ipv6 ? 0 : "admin_cidr_ipv6 must be a valid IPv6 CIDR (e.g. 2001:db8::/64)"
  ) : 0
  validate_gateway_addresses_ipv6_format = var.gateway_addresses_ipv6 != "" ? (
    regex(local.regex_valid_ipv6_cidr, var.gateway_addresses_ipv6) == var.gateway_addresses_ipv6 ? 0 : "gateway_addresses_ipv6 must be a valid IPv6 CIDR (e.g. 2001:db8::/64)"
  ) : 0
}
