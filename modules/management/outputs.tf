output "Deployment" {
  description = "Deployment notice"
  value       = "Finalizing configuration may take up to 20 minutes after deployment is finished"
}

output "management_instance_id" {
  description = "The ECS instance ID of the management server"
  value       = module.instance.management_instance_id
}

output "management_instance_name" {
  description = "The name tag of the management instance"
  value       = module.instance.management_instance_name
}

output "management_public_ip" {
  description = "The Elastic IP address of the management server (empty if EIP not allocated)"
  value       = module.elastic_ip.instance_eip_public_ip
}

output "management_sg_id" {
  description = "The ID of the management server security group"
  value       = module.instance.management_sg_id
}

output "vpc_id" {
  description = "The VPC ID (existing or newly created)"
  value       = local.resolved_vpc_id
}

output "management_ipv6_address" {
  description = "The IPv6 address of the management instance (empty if IPv4 only)"
  value       = var.enable_ipv6 ? module.instance.management_ipv6_address : ""
}

output "ipv6_gateway_id" {
  description = "The IPv6 gateway ID (empty if IPv4 only)"
  value       = var.enable_ipv6 ? module.ipv6_internet[0].ipv6_gateway_id : ""
}
