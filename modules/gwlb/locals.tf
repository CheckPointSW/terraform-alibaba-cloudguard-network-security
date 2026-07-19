locals {
  // VPC mode — false means use existing VPC/vSwitches
  create_vpc = var.vpc_id == ""

  validate_vpc_mode = regex("^$", (
    local.create_vpc && length(var.security_vswitchs_map) == 0
    ? "security_vswitchs_map must be provided when creating a new VPC (vpc_id is empty)"
    : !local.create_vpc && length(var.security_vswitchs_ids) == 0
    ? "security_vswitchs_ids must be provided when using an existing VPC"
    : ""
  ))

  resolved_vpc_id = local.create_vpc ? alicloud_vpc.security_vpc[0].id : var.vpc_id

  resolved_vswitches = local.create_vpc ? {
    for zone, vsw in alicloud_vswitch.security_vswitch : zone => {
      id      = vsw.id
      zone_id = vsw.zone_id
    }
  } : {
    for vsw_id, ds in data.alicloud_vswitches.existing : ds.vswitches[0].zone_id => {
      id      = vsw_id
      zone_id = ds.vswitches[0].zone_id
    }
  }
}

locals {
  // Cross-variable: desired_capacity must sit between min and max
  validate_scale_set_sizes = regex("^$", (
    var.min_group_size <= var.desired_capacity && var.desired_capacity <= var.max_group_size
    ? ""
    : "desired_capacity (${var.desired_capacity}) must be between min_group_size (${var.min_group_size}) and max_group_size (${var.max_group_size})"
  ))
}
