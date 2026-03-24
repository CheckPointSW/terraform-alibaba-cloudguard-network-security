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

output "image_id" {
  description = "The image ID used to launch the management server"
  value       = module.images.image_id
}

output "vpc_id" {
  description = "The VPC ID (existing or newly created)"
  value       = local.resolved_vpc_id
}
