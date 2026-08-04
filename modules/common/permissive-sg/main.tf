resource "alicloud_security_group" "permissive_sg" {
  security_group_name = format("%s-PermissiveSecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  description         = "Permissive security group"
  vpc_id              = var.vpc_id
}

resource "alicloud_security_group_rule" "permissive_egress" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "permissive_ingress" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  cidr_ip           = "0.0.0.0/0"
}

// --- IPv6 rules (dual-stack only) ---
resource "alicloud_security_group_rule" "permissive_egress_ipv6" {
  count             = var.enable_ipv6 ? 1 : 0
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  ipv6_cidr_ip      = "::/0"
}

resource "alicloud_security_group_rule" "permissive_ingress_ipv6" {
  count             = var.enable_ipv6 ? 1 : 0
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  ipv6_cidr_ip      = "::/0"
}
