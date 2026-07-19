resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "alicloud_ess_scaling_group" "gw_scaling_group" {
  scaling_group_name = format("%s-scaling-group-%s", var.prefix, random_string.suffix.result)
  min_size           = var.min_group_size
  max_size           = var.max_group_size
  desired_capacity   = var.desired_capacity
  vswitch_ids        = [for vsw in var.vswitches : vsw.id]
  multi_az_policy    = var.multi_az_policy
  removal_policies   = ["OldestScalingConfiguration", "OldestInstance"]
}

resource "alicloud_ess_server_group_attachment" "gwlb_ess_attachment" {
  scaling_group_id = alicloud_ess_scaling_group.gw_scaling_group.id
  server_group_id  = alicloud_gwlb_server_group.gwlb_sg.id
  type             = "GWLB"
  force_attach     = true
}

resource "alicloud_ess_scaling_configuration" "gw_config" {
  scaling_group_id           = alicloud_ess_scaling_group.gw_scaling_group.id
  scaling_configuration_name = format("%s-scaling-config", var.prefix)
  image_id                   = var.image_id
  instance_type              = var.gateway_instance_type
  security_group_ids         = [var.sg_id]
  key_name                   = var.key_name
  system_disk_category       = var.disk_category
  system_disk_size           = var.volume_size
  internet_charge_type       = var.gateway_internet_charge_type
  internet_max_bandwidth_out = var.allocate_public_ip ? var.gateway_internet_max_bandwidth_out : 0
  instance_name              = format("%s-gw-(AUTO_INCREMENT)[1,3]", var.prefix)
  host_name                  = format("%s-gw-(AUTO_INCREMENT)[1,3]", var.prefix)
  force_delete               = true
  active                     = true
  enable                     = true

  user_data = base64encode(templatefile("${path.module}/gateway_userdata.yaml", {
    PasswordHash           = local.gateway_password_hash_base64
    Shell                  = var.admin_shell
    SICKey                 = local.gateway_SICkey_base64
    GatewayBootstrapScript = local.gateway_bootstrap_script64
    Hostname               = ""
    AllowUploadDownload    = var.allow_upload_download
    NTPPrimary             = var.primary_ntp
    NTPSecondary           = var.secondary_ntp
    OsVersion              = local.version_split
    TemplateVersion        = "1.0"
  }))

  tags = merge(var.instance_tags, {
    "x-chkp-management"           = var.management_name
    "x-chkp-template"             = var.configuration_template_name
    "x-chkp-management-interface" = "eth0"
    "x-chkp-ip-address"           = var.allocate_public_ip ? "public" : "private"
    "x-chkp-topology"             = "external"
    "x-chkp-anti-spoofing"        = "false"
    "x-chkp-scale-set-name"       = alicloud_ess_scaling_group.gw_scaling_group.scaling_group_name
  })
}

resource "alicloud_ess_scaling_rule" "cpu_rule" {
  scaling_group_id          = alicloud_ess_scaling_group.gw_scaling_group.id
  scaling_rule_name         = format("%s-cpu-rule", var.prefix)
  scaling_rule_type         = "TargetTrackingScalingRule"
  metric_name               = "CpuUtilization"
  target_value              = var.cpu_usage
  estimated_instance_warmup = 300
}

resource "alicloud_gwlb_load_balancer" "gwlb" {
  vpc_id             = var.vpc_id
  load_balancer_name = "${var.prefix}-gwlb"

  dynamic "zone_mappings" {
    for_each = var.vswitches
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }
}

resource "alicloud_gwlb_server_group" "gwlb_sg" {
  vpc_id            = var.vpc_id
  server_group_name = "${var.prefix}-server-group"
  server_group_type = "Instance"
  protocol          = "GENEVE"
  scheduler         = "5TCH"

  health_check_config {
    health_check_enabled         = true
    health_check_protocol        = "TCP"
    health_check_connect_port    = 8117
    health_check_connect_timeout = 5
    health_check_interval        = 10
    healthy_threshold            = 2
    unhealthy_threshold          = 2
  }

  connection_drain_config {
    connection_drain_enabled = true
    connection_drain_timeout = var.connection_drain_timeout
  }
}

resource "alicloud_gwlb_listener" "gwlb_listener" {
  load_balancer_id     = alicloud_gwlb_load_balancer.gwlb.id
  server_group_id      = alicloud_gwlb_server_group.gwlb_sg.id
  listener_description = format("%s-listener", var.prefix)
}

resource "alicloud_privatelink_vpc_endpoint_service" "gwlb_service" {
  service_description    = format("%s endpoint service", var.prefix)
  service_resource_type  = "gwlb"
  auto_accept_connection = true
}

resource "alicloud_privatelink_vpc_endpoint_service_resource" "gwlb_resource" {
  for_each      = var.vswitches
  service_id    = alicloud_privatelink_vpc_endpoint_service.gwlb_service.id
  resource_id   = alicloud_gwlb_load_balancer.gwlb.id
  resource_type = "gwlb"
  zone_id       = each.key
}
