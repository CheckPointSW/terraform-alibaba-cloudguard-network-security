locals {
  version_split                = element(split("-", var.version_license), 0)
  gateway_bootstrap_script64   = base64encode(var.bootstrap_script)
  gateway_SICkey_base64        = base64encode(var.SICKey)
  gateway_password_hash_base64 = base64encode(var.password_hash)
}
