output "member_a_instance_id" {
  value = alicloud_instance.member_a.id
}

output "member_b_instance_id" {
  value = alicloud_instance.member_b.id
}

output "member_a_instance_name" {
  value = alicloud_instance.member_a.instance_name
}

output "member_b_instance_name" {
  value = alicloud_instance.member_b.instance_name
}

output "member_a_mgmt_eni_id" {
  value = alicloud_network_interface.member_a_mgmt_eni.id
}

output "member_b_mgmt_eni_id" {
  value = alicloud_network_interface.member_b_mgmt_eni.id
}

output "member_a_internal_eni_id" {
  value = alicloud_network_interface.member_a_internal_eni.id
}

output "member_b_internal_eni_id" {
  value = alicloud_network_interface.member_b_internal_eni.id
}
