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
  resolved_vpc_id             = local.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  resolved_public_vswitch_id  = local.create_vpc ? module.vpc[0].public_vswitchs_ids_list[0] : var.public_vswitch_id
  resolved_private_vswitch_id = local.create_vpc ? module.vpc[0].private_vswitchs_ids_list[0] : var.private_vswitch_id
}
