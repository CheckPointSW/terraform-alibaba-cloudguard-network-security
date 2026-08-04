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

output "vpc_id" {
  description = "The VPC ID (existing or newly created)"
  value       = local.resolved_vpc_id
}

output "gateway_ipv6_address" {
  description = "The IPv6 address of the gateway instance (empty if IPv4 only)"
  value       = var.enable_ipv6 ? module.instance.gateway_ipv6_address : ""
}

output "internal_eni_ipv6_address" {
  description = "The IPv6 address of the internal ENI (empty if IPv4 only)"
  value       = var.enable_ipv6 ? module.instance.internal_eni_ipv6_address : ""
}

output "ipv6_gateway_id" {
  description = "The IPv6 gateway ID (empty if IPv4 only)"
  value       = var.enable_ipv6 ? module.ipv6_internet[0].ipv6_gateway_id : ""
}
