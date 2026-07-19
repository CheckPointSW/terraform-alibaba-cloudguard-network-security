module "validate" {
  source           = "../common/validations"
  chkp_type        = "gateway"
  instance_type    = var.gateway_instance_type
  version_license  = var.gateway_version
  volume_size      = var.volume_size
  admin_shell      = var.admin_shell
  sic_key          = var.gateway_SICKey
  password_hash    = var.gateway_password_hash
  vpc_id           = var.vpc_id
  key_name         = var.key_name
  bootstrap_script = var.gateway_bootstrap_script
}

resource "alicloud_vpc" "security_vpc" {
  count      = local.create_vpc ? 1 : 0
  vpc_name   = "${var.prefix}-security-vpc"
  cidr_block = var.security_vpc_cidr
}

resource "alicloud_vswitch" "security_vswitch" {
  for_each     = local.create_vpc ? var.security_vswitchs_map : {}
  vpc_id       = alicloud_vpc.security_vpc[0].id
  zone_id      = each.key
  cidr_block   = cidrsubnet(var.security_vpc_cidr, var.vswitchs_bit_length, each.value)
  vswitch_name = format("%s-security-vswitch-%s", var.prefix, each.value)
}

// Look up each existing vSwitch's zone so the user can pass just IDs
// while downstream resources (GWLB zone_mappings, PrivateLink) still get the zone.
data "alicloud_vswitches" "existing" {
  for_each = local.create_vpc ? toset([]) : toset(var.security_vswitchs_ids)
  ids      = [each.value]
}

module "images" {
  source          = "../common/images"
  version_license = var.gateway_version
  chkp_type       = "gateway"
}

module "permissive_sg" {
  source             = "../common/permissive-sg"
  vpc_id             = local.resolved_vpc_id
  resources_tag_name = var.prefix
  gateway_name       = format("%s-gw", var.prefix)
}

module "gwlb" {
  source = "./scaleset"

  prefix    = var.prefix
  vpc_id    = local.resolved_vpc_id
  vswitches = local.resolved_vswitches
  image_id  = module.images.image_id
  sg_id     = module.permissive_sg.permissive_sg_id

  key_name                           = var.key_name
  gateway_instance_type              = var.gateway_instance_type
  gateway_version                    = var.gateway_version
  gateway_SICKey                     = var.gateway_SICKey
  gateway_password_hash              = var.gateway_password_hash
  gateway_bootstrap_script           = var.gateway_bootstrap_script
  admin_shell                        = var.admin_shell
  volume_size                        = var.volume_size
  disk_category                      = var.disk_category
  allocate_public_ip                 = var.allocate_public_ip
  gateway_internet_charge_type       = var.gateway_internet_charge_type
  gateway_internet_max_bandwidth_out = var.gateway_internet_max_bandwidth_out
  min_group_size                     = var.min_group_size
  max_group_size                     = var.max_group_size
  desired_capacity                   = var.desired_capacity
  cpu_usage                          = var.cpu_usage
  multi_az_policy                    = var.multi_az_policy
  connection_drain_timeout           = var.connection_drain_timeout
  management_name                    = var.management_name
  configuration_template_name        = var.configuration_template_name
  allow_upload_download              = var.allow_upload_download
  primary_ntp                        = var.primary_ntp
  secondary_ntp                      = var.secondary_ntp
  instance_tags                      = var.instance_tags
}
