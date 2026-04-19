// --- Internal ENI (eth1) ---
resource "alicloud_network_interface" "internal_eni" {
  network_interface_name = format("%s-internal-eni", var.eni_name_prefix)
  vswitch_id             = var.private_vswitch_id
  security_group_ids     = var.security_groups
  description            = "eth1"
}

resource "alicloud_instance" "gateway_instance" {
  instance_name        = var.gateway_name
  instance_type        = var.gateway_instance_type
  key_name             = var.key_name
  image_id             = var.image_id
  vswitch_id           = var.vswitch_id
  security_groups      = var.security_groups
  system_disk_size     = var.volume_size
  system_disk_category = var.disk_category

  network_interfaces {
    network_interface_id = alicloud_network_interface.internal_eni.id
  }

  tags = merge({
    Name = var.gateway_name
  }, var.instance_tags)

  user_data = templatefile("${path.module}/gateway_userdata.yaml", {
    PasswordHash           = local.gateway_password_hash_base64
    Shell                  = var.admin_shell
    SICKey                 = local.gateway_SICkey_base64
    TokenKey               = var.gateway_TokenKey
    GatewayBootstrapScript = local.gateway_bootstrap_script64
    Hostname               = var.gateway_hostname
    AllowUploadDownload    = var.allow_upload_download
    NTPPrimary             = var.primary_ntp
    NTPSecondary           = var.secondary_ntp
    OsVersion              = local.version_split
    TemplateVersion        = "1.0"
  })
}
