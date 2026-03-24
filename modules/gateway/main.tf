// --- Validations ---
module "validate" {
  source          = "../common/validations"
  chkp_type       = "gateway"
  instance_type   = var.gateway_instance_type
  version_license = var.gateway_version
  volume_size     = var.volume_size
  admin_shell     = var.admin_shell
  hostname        = var.gateway_hostname
  sic_key         = var.gateway_SICKey
  token           = var.gateway_TokenKey
}

// --- VPC (created only when vpc_id is not provided) ---
module "vpc" {
  count  = local.create_vpc ? 1 : 0
  source = "../common/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_vswitchs_map  = var.public_vswitchs_map
  private_vswitchs_map = var.private_vswitchs_map
  vswitchs_bit_length  = var.vswitchs_bit_length
}

// --- Route table (created only when a new VPC is created) ---
resource "alicloud_route_table" "private_vswitch_rt" {
  count            = local.create_vpc ? 1 : 0
  depends_on       = [module.vpc]
  route_table_name = "Internal_Route_Table"
  vpc_id           = module.vpc[0].vpc_id
}

resource "alicloud_route_table_attachment" "private_rt_to_private_vswitchs" {
  count          = local.create_vpc ? 1 : 0
  depends_on     = [module.vpc, alicloud_route_table.private_vswitch_rt]
  route_table_id = alicloud_route_table.private_vswitch_rt[0].id
  vswitch_id     = module.vpc[0].private_vswitchs_ids_list[0]
}

// --- Image ---
module "images" {
  source = "../common/images"

  version_license = var.gateway_version
  chkp_type       = "gateway"
}

// --- Security Group ---
module "permissive_sg" {
  source = "../common/permissive-sg"

  vpc_id             = local.resolved_vpc_id
  resources_tag_name = var.resources_tag_name
  gateway_name       = var.gateway_name
}

// --- Gateway Instance ---
module "instance" {
  source = "./instance"

  gateway_name             = var.gateway_name
  gateway_instance_type    = var.gateway_instance_type
  key_name                 = var.key_name
  vswitch_id               = local.resolved_public_vswitch_id
  volume_size              = var.volume_size
  disk_category            = var.disk_category
  image_id                 = module.images.image_id
  security_groups          = [module.permissive_sg.permissive_sg_id]
  instance_tags            = var.instance_tags
  gateway_version          = var.gateway_version
  admin_shell              = var.admin_shell
  gateway_SICKey           = var.gateway_SICKey
  gateway_password_hash    = var.gateway_password_hash
  gateway_TokenKey         = var.gateway_TokenKey
  gateway_bootstrap_script = var.gateway_bootstrap_script
  gateway_hostname         = var.gateway_hostname
  allow_upload_download    = var.allow_upload_download
  primary_ntp              = var.primary_ntp
  secondary_ntp            = var.secondary_ntp
  private_vswitch_id       = local.resolved_private_vswitch_id
  eni_name_prefix          = var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name
}

// --- Default Route via Internal ENI ---
module "internal_default_route" {
  count  = (var.private_route_table != "" || local.create_vpc) ? 1 : 0
  source = "../common/internal-default-route"

  private_route_table = local.create_vpc ? alicloud_route_table.private_vswitch_rt[0].id : var.private_route_table
  internal_eni_id     = module.instance.internal_eni_id
}

// --- Elastic IP ---
module "elastic_ip" {
  source = "../common/elastic-ip"

  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id                = module.instance.gateway_instance_id
  eip_name                   = format("%s-eip", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
}

// --- RAM Role Attachment ---
resource "alicloud_ram_role_attachment" "attach" {
  count        = var.ram_role_name != "" ? 1 : 0
  role_name    = var.ram_role_name
  instance_ids = [module.instance.gateway_instance_id]
}
