// Public-IPv6 infrastructure is created only when ipv6_internet_bandwidth > 0.
// bandwidth = 0 means VPC-internal IPv6 only: no gateway, no bandwidth, no public route.
locals {
  create_public_ipv6       = var.ipv6_internet_bandwidth > 0
  resolved_ipv6_gateway_id = var.create_ipv6_gateway && local.create_public_ipv6 ? alicloud_vpc_ipv6_gateway.ipv6_gw[0].id : var.ipv6_gateway_id
}
