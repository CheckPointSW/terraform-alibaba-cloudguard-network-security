output "instance_eip_id" {
  value = alicloud_eip.instance_eip.*.id
}

output "instance_eip_public_ip" {
  // Single string ("" when no EIP) rather than a list, so consumers' public-IP
  // outputs render as a scalar to match their documented shape.
  value = try(alicloud_eip.instance_eip[0].ip_address, "")
}
