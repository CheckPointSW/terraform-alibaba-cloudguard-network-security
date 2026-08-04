// --- IPv6 Gateway (created only for new VPCs that need public IPv6) ---
resource "alicloud_vpc_ipv6_gateway" "ipv6_gw" {
  count             = var.create_ipv6_gateway && local.create_public_ipv6 ? 1 : 0
  ipv6_gateway_name = var.ipv6_gateway_name
  vpc_id            = var.vpc_id
}

// --- Look up the IPv6 address assigned to the instance on the given vSwitch ---
data "alicloud_vpc_ipv6_addresses" "instance_ipv6" {
  count                  = local.create_public_ipv6 ? 1 : 0
  associated_instance_id = var.instance_id
  vswitch_id             = var.vswitch_id
  status                 = "Available"
}

// --- IPv6 Internet Bandwidth (enables public IPv6 connectivity) ---
resource "alicloud_vpc_ipv6_internet_bandwidth" "ipv6_bandwidth" {
  count                = local.create_public_ipv6 ? 1 : 0
  ipv6_address_id      = data.alicloud_vpc_ipv6_addresses.instance_ipv6[0].addresses[0].id
  ipv6_gateway_id      = local.resolved_ipv6_gateway_id
  internet_charge_type = var.ipv6_internet_charge_type
  bandwidth            = var.ipv6_internet_bandwidth
}
