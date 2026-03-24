// --- Validations ---
module "validate" {
  source          = "../common/validations"
  chkp_type       = "management"
  instance_type   = var.instance_type
  version_license = var.version_license
  volume_size     = var.volume_size
  admin_shell     = var.admin_shell
  hostname        = var.hostname
  sic_key         = var.SICKey
}

// --- VPC (created only when vpc_id is not provided) ---
module "vpc" {
  count  = local.create_vpc ? 1 : 0
  source = "../common/vpc"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  public_vswitchs_map = var.public_vswitchs_map
  vswitchs_bit_length = var.vswitchs_bit_length
}

// --- Image ---
module "images" {
  source = "../common/images"

  version_license = var.version_license
  chkp_type       = "management"
}

// --- Management Instance (SG + ECS) ---
module "instance" {
  source = "./instance"

  vpc_id                     = local.resolved_vpc_id
  vswitch_id                 = local.resolved_vswitch
  instance_name              = var.instance_name
  instance_type              = var.instance_type
  key_name                   = var.key_name
  volume_size                = var.volume_size
  disk_category              = var.disk_category
  instance_tags              = var.instance_tags
  image_id                   = module.images.image_id
  version_license            = var.version_license
  admin_shell                = var.admin_shell
  password_hash              = var.password_hash
  hostname                   = var.hostname
  is_primary_management      = var.is_primary_management
  SICKey                     = var.SICKey
  allow_upload_download      = var.allow_upload_download
  gateway_management         = var.gateway_management
  admin_cidr                 = var.admin_cidr
  gateway_addresses          = var.gateway_addresses
  primary_ntp                = var.primary_ntp
  secondary_ntp              = var.secondary_ntp
  bootstrap_script           = var.bootstrap_script
  allocate_and_associate_eip = var.allocate_and_associate_eip
}

// --- Elastic IP ---
module "elastic_ip" {
  source = "../common/elastic-ip"

  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id                = module.instance.management_instance_id
}

// --- RAM Role Attachment ---
resource "alicloud_ram_role_attachment" "attach" {
  count        = var.ram_role_name != "" ? 1 : 0
  role_name    = var.ram_role_name
  instance_ids = [module.instance.management_instance_id]
}
