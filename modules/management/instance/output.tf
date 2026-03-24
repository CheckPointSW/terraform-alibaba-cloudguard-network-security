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
