output "scaling_group_id" {
  description = "ESS scaling group ID"
  value       = alicloud_ess_scaling_group.gw_scaling_group.id
}

output "gwlb_id" {
  description = "GWLB load balancer ID"
  value       = alicloud_gwlb_load_balancer.gwlb.id
}

output "gwlb_server_group_id" {
  description = "GWLB server group ID"
  value       = alicloud_gwlb_server_group.gwlb_sg.id
}

output "endpoint_service_id" {
  description = "PrivateLink endpoint service ID"
  value       = alicloud_privatelink_vpc_endpoint_service.gwlb_service.id
}
