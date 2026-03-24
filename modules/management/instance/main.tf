// --- Management Security Group ---
resource "alicloud_security_group" "management_sg" {
  security_group_name = format("%s-SecurityGroup", var.instance_name)
  description         = "Management server security group"
  vpc_id              = var.vpc_id
}

resource "alicloud_security_group_rule" "permissive_egress" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = "0.0.0.0/0"
}

// Gateway-facing rules (TCP)
resource "alicloud_security_group_rule" "management_ingress_257" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "257/257"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress_8211" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8211/8211"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress_18191_18192" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18191/18192"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress_18210_18211" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18210/18211"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress_18221" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18221/18221"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress_18264" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18264/18264"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

// Gateway-facing ICMP
resource "alicloud_security_group_rule" "management_ingress_gw_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

// Admin-facing rules (TCP)
resource "alicloud_security_group_rule" "management_ingress_22" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress_443" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress_18190" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18190/18190"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress_19009" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "19009/19009"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

// Admin-facing ICMP
resource "alicloud_security_group_rule" "management_ingress_admin_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 2
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

// --- Management ECS Instance ---
resource "alicloud_instance" "management_instance" {
  instance_name        = var.instance_name
  instance_type        = var.instance_type
  key_name             = var.key_name
  image_id             = var.image_id
  vswitch_id           = var.vswitch_id
  security_groups      = [alicloud_security_group.management_sg.id]
  system_disk_size     = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = var.instance_name
  }, var.instance_tags)

  user_data = templatefile("${path.module}/management_userdata.yaml", {
    Hostname           = var.hostname
    PasswordHash       = local.gateway_password_hash_base64
    AllowUploadDownload = var.allow_upload_download
    NTPPrimary         = var.primary_ntp
    NTPSecondary       = var.secondary_ntp
    Shell              = var.admin_shell
    AdminSubnet        = var.admin_cidr
    IsPrimary          = var.is_primary_management
    SICKey             = local.gateway_SICkey_base64
    AllocateElasticIP  = var.allocate_and_associate_eip
    GatewayManagement  = var.gateway_management
    BootstrapScript    = local.gateway_bootstrap_script64
    OsVersion          = local.version_split
    TemplateVersion    = "1.0"
  })
}
