output "vpc_id" {
  value = alicloud_vpc.vpc.id
}

output "vpc_name" {
  value = alicloud_vpc.vpc.vpc_name
}

output "public_vswitchs_ids_list" {
  value = [for vsw in alicloud_vswitch.publicVsw : vsw.id]
}

output "management_vswitchs_ids_list" {
  value = [for vsw in alicloud_vswitch.managementVsw : vsw.id]
}

output "private_vswitchs_ids_list" {
  value = [for vsw in alicloud_vswitch.privateVsw : vsw.id]
}
