output "management_instance_id" {
  value = alicloud_instance.management_instance.id
}

output "management_instance_name" {
  value = alicloud_instance.management_instance.tags["Name"]
}

output "management_instance_tags" {
  value = alicloud_instance.management_instance.tags
}

output "management_sg_id" {
  value = alicloud_security_group.management_sg.id
}

output "management_ipv6_address" {
  description = "The IPv6 address of the management instance (empty if IPv4 only or no address assigned yet)"
  value       = var.enable_ipv6 ? try(tolist(alicloud_instance.management_instance.ipv6_addresses)[0], "") : ""
}
