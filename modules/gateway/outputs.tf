output "gateway_instance_id" {
  description = "The ECS instance ID of the gateway"
  value       = module.instance.gateway_instance_id
}

output "gateway_instance_name" {
  description = "The name tag of the gateway instance"
  value       = module.instance.gateway_instance_name
}

output "gateway_public_ip" {
  description = "The Elastic IP address associated with the gateway (empty if EIP not allocated)"
  value       = module.elastic_ip.instance_eip_public_ip
}

output "internal_eni_id" {
  description = "The ID of the gateway's internal (eth1) ENI"
  value       = module.instance.internal_eni_id
}

output "permissive_sg_id" {
  description = "The ID of the permissive security group"
  value       = module.permissive_sg.permissive_sg_id
}

output "image_id" {
  description = "The image ID used to launch the gateway"
  value       = module.images.image_id
}

output "vpc_id" {
  description = "The VPC ID (existing or newly created)"
  value       = local.resolved_vpc_id
}
