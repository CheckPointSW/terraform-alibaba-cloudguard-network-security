locals {
  // --- VPC Mode ---
  create_vpc = var.vpc_id == ""

  // Will fail if neither an existing vpc_id nor a new VPC map is provided
  validate_vpc_mode = regex("^$", (
    local.create_vpc && length(var.public_vswitchs_map) == 0
    ? "Must provide either vpc_id (existing VPC) or public_vswitchs_map (new VPC)"
    : ""
  ))

  // Resolve VPC and vSwitch IDs from whichever mode is configured
  resolved_vpc_id    = local.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  resolved_vswitch   = local.create_vpc ? module.vpc[0].public_vswitchs_ids_list[0] : var.vswitch_id

  // --- Management-specific validations ---
  gateway_management_allowed_values = [
    "Locally managed",
    "Over the internet"
  ]
  // Will fail if var.gateway_management is not in the allowed list
  validate_gateway_management = index(local.gateway_management_allowed_values, var.gateway_management)

  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"
  // Will fail if var.admin_cidr is not a valid CIDR
  validate_admin_cidr = regex(local.regex_valid_cidr_range, var.admin_cidr) == var.admin_cidr ? 0 : "var.admin_cidr must be a valid CIDR range"
  // Will fail if var.gateway_addresses is not a valid CIDR
  validate_gateway_addresses = regex(local.regex_valid_cidr_range, var.gateway_addresses) == var.gateway_addresses ? 0 : "var.gateway_addresses must be a valid CIDR range"
}
