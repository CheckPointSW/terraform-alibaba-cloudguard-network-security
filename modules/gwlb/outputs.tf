// --- Security VPC ---

output "security_vpc_id" {
  description = "Security VPC ID (created or existing)"
  value       = local.resolved_vpc_id
}

output "security_vswitch_ids" {
  description = "Map of {zone = vswitch-id} for the security vSwitches"
  value       = { for zone, vsw in local.resolved_vswitches : zone => vsw.id }
}

// --- Scale Set ---

output "scaling_group_id" {
  description = "ESS scaling group ID"
  value       = module.gwlb.scaling_group_id
}

// --- GWLB ---

output "gwlb_id" {
  description = "GWLB load balancer ID"
  value       = module.gwlb.gwlb_id
}

output "gwlb_server_group_id" {
  description = "GWLB server group ID"
  value       = module.gwlb.gwlb_server_group_id
}

// --- PrivateLink ---

output "endpoint_service_id" {
  description = "PrivateLink endpoint service ID — provide this to the customer to create the GWLBe"
  value       = module.gwlb.endpoint_service_id
}
