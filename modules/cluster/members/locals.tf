locals {
  // Hostname: when gateway_hostname is empty, use bare "member-a"/"member-b" to avoid invalid "-member-a"
  hostname_member_a = var.gateway_hostname != "" ? "${var.gateway_hostname}-member-a" : "member-a"
  hostname_member_b = var.gateway_hostname != "" ? "${var.gateway_hostname}-member-b" : "member-b"

  version_split                = element(split("-", var.gateway_version), 0)
  gateway_bootstrap_script64   = base64encode(var.gateway_bootstrap_script)
  gateway_SICkey_base64        = base64encode(var.gateway_SICKey)
  gateway_password_hash_base64 = base64encode(var.gateway_password_hash)

  eni_name_prefix = var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name
}
