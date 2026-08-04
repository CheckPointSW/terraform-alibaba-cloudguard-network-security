output "gateway_instance_id" {
  value = alicloud_instance.gateway_instance.id
}

output "gateway_instance_name" {
  value = alicloud_instance.gateway_instance.tags["Name"]
}

output "internal_eni_id" {
  value = alicloud_network_interface.internal_eni.id
}

output "gateway_ipv6_address" {
  description = "The IPv6 address of the gateway instance (empty if IPv4 only or no address assigned yet)"
  value       = var.enable_ipv6 ? try(tolist(alicloud_instance.gateway_instance.ipv6_addresses)[0], "") : ""
}

output "internal_eni_ipv6_address" {
  description = "The IPv6 address of the internal ENI (empty if IPv4 only or no address assigned yet)"
  value       = var.enable_ipv6 ? try(tolist(alicloud_network_interface.internal_eni.ipv6_addresses)[0], "") : ""
}
