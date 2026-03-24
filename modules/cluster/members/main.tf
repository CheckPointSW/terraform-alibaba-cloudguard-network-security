// --- Member A Instance ---
resource "alicloud_instance" "member_a" {
  instance_name        = format("%s-Member-A", var.gateway_name)
  instance_type        = var.gateway_instance_type
  key_name             = var.key_name
  image_id             = var.image_id
  vswitch_id           = var.cluster_vswitch_id
  security_groups      = [var.permissive_sg_id]
  system_disk_size     = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = format("%s-Member-A", var.gateway_name)
  }, var.instance_tags)

  user_data = templatefile("${path.module}/cluster_member_userdata.yaml", {
    Hostname               = local.hostname_member_a
    PasswordHash           = local.gateway_password_hash_base64
    AllowUploadDownload    = var.allow_upload_download
    NTPPrimary             = var.primary_ntp
    NTPSecondary           = var.secondary_ntp
    Shell                  = var.admin_shell
    GatewayBootstrapScript = local.gateway_bootstrap_script64
    SICKey                 = local.gateway_SICkey_base64
    Token                  = var.memberAToken
    ManagementIpAddress    = var.management_ip_address
    OsVersion              = local.version_split
    TemplateVersion        = "1.0"
  })
}

// --- Member B Instance ---
resource "alicloud_instance" "member_b" {
  instance_name        = format("%s-Member-B", var.gateway_name)
  instance_type        = var.gateway_instance_type
  key_name             = var.key_name
  image_id             = var.image_id
  vswitch_id           = var.cluster_vswitch_id
  security_groups      = [var.permissive_sg_id]
  system_disk_size     = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = format("%s-Member-B", var.gateway_name)
  }, var.instance_tags)

  user_data = templatefile("${path.module}/cluster_member_userdata.yaml", {
    Hostname               = local.hostname_member_b
    PasswordHash           = local.gateway_password_hash_base64
    AllowUploadDownload    = var.allow_upload_download
    NTPPrimary             = var.primary_ntp
    NTPSecondary           = var.secondary_ntp
    Shell                  = var.admin_shell
    GatewayBootstrapScript = local.gateway_bootstrap_script64
    SICKey                 = local.gateway_SICkey_base64
    Token                  = var.memberBToken
    ManagementIpAddress    = var.management_ip_address
    OsVersion              = local.version_split
    TemplateVersion        = "1.0"
  })
}

// --- Management ENIs (eth2) ---
resource "alicloud_network_interface" "member_a_mgmt_eni" {
  network_interface_name = format("%s-Member-A-management-eni", local.eni_name_prefix)
  vswitch_id             = var.mgmt_vswitch_id
  security_group_ids     = [var.permissive_sg_id]
  description            = "eth2"
}

resource "alicloud_network_interface_attachment" "member_a_mgmt_eni_attachment" {
  instance_id          = alicloud_instance.member_a.id
  network_interface_id = alicloud_network_interface.member_a_mgmt_eni.id
}

resource "alicloud_network_interface" "member_b_mgmt_eni" {
  network_interface_name = format("%s-Member-B-management-eni", local.eni_name_prefix)
  vswitch_id             = var.mgmt_vswitch_id
  security_group_ids     = [var.permissive_sg_id]
  description            = "eth2"
}

resource "alicloud_network_interface_attachment" "member_b_mgmt_eni_attachment" {
  instance_id          = alicloud_instance.member_b.id
  network_interface_id = alicloud_network_interface.member_b_mgmt_eni.id
}

// --- Internal ENIs (eth1) ---
resource "alicloud_network_interface" "member_a_internal_eni" {
  depends_on             = [alicloud_network_interface_attachment.member_a_mgmt_eni_attachment]
  network_interface_name = format("%s-Member-A-internal-eni", local.eni_name_prefix)
  vswitch_id             = var.private_vswitch_id
  security_group_ids     = [var.permissive_sg_id]
  description            = "eth1"
}

resource "alicloud_network_interface_attachment" "member_a_internal_eni_attachment" {
  instance_id          = alicloud_instance.member_a.id
  network_interface_id = alicloud_network_interface.member_a_internal_eni.id
}

resource "alicloud_network_interface" "member_b_internal_eni" {
  depends_on             = [alicloud_network_interface_attachment.member_b_mgmt_eni_attachment, alicloud_network_interface_attachment.member_a_internal_eni_attachment]
  network_interface_name = format("%s-Member-B-internal-eni", local.eni_name_prefix)
  vswitch_id             = var.private_vswitch_id
  security_group_ids     = [var.permissive_sg_id]
  description            = "eth1"
}

resource "alicloud_network_interface_attachment" "member_b_internal_eni_attachment" {
  instance_id          = alicloud_instance.member_b.id
  network_interface_id = alicloud_network_interface.member_b_internal_eni.id
}
