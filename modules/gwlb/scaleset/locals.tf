locals {
  version_split                = element(split("-", var.gateway_version), 0)
  gateway_bootstrap_script64   = base64encode(var.gateway_bootstrap_script)
  gateway_SICkey_base64        = base64encode(var.gateway_SICKey)
  gateway_password_hash_base64 = base64encode(var.gateway_password_hash)
}
