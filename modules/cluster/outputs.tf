output "cluster_primary_eip" {
  description = "Public IP of the cluster primary EIP (associated with Member A)"
  value       = module.cluster_primary_eip.instance_eip_public_ip
}

output "cluster_secondary_eip" {
  description = "Public IP of the cluster secondary EIP (associated with Member B)"
  value       = module.cluster_secondary_eip.instance_eip_public_ip
}

output "member_a_eip" {
  description = "Public IP of Member A's management EIP (empty if not allocated)"
  value       = module.member_a_mgmt_eip.instance_eip_public_ip
}

output "member_b_eip" {
  description = "Public IP of Member B's management EIP (empty if not allocated)"
  value       = module.member_b_mgmt_eip.instance_eip_public_ip
}

output "member_a_instance_id" {
  description = "ECS instance ID of Member A"
  value       = module.members.member_a_instance_id
}

output "member_b_instance_id" {
  description = "ECS instance ID of Member B"
  value       = module.members.member_b_instance_id
}

output "member_a_instance_name" {
  description = "Instance name of Member A"
  value       = module.members.member_a_instance_name
}

output "member_b_instance_name" {
  description = "Instance name of Member B"
  value       = module.members.member_b_instance_name
}

output "member_a_internal_eni_id" {
  description = "Internal ENI ID of Member A"
  value       = module.members.member_a_internal_eni_id
}

output "permissive_sg_id" {
  description = "ID of the permissive security group"
  value       = module.permissive_sg.permissive_sg_id
}

output "permissive_sg_name" {
  description = "Name of the permissive security group"
  value       = module.permissive_sg.permissive_sg_name
}

output "image_id" {
  description = "The image ID used to launch the cluster members"
  value       = module.images.image_id
}

output "vpc_id" {
  description = "The VPC ID (existing or newly created)"
  value       = local.resolved_vpc_id
}
