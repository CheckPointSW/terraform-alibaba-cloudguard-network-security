resource "alicloud_route_entry" "internal_default_route" {
  route_table_id        = var.private_route_table
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = var.internal_eni_id
}

resource "alicloud_route_entry" "internal_default_route_ipv6" {
  count                 = var.enable_ipv6 ? 1 : 0
  route_table_id        = var.private_route_table
  destination_cidrblock = "::/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = var.internal_eni_id
}
