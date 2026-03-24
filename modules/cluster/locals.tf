locals {
  // --- VPC Mode ---
  create_vpc = var.vpc_id == ""

  // Will fail if neither an existing vpc_id nor new VPC maps are provided
  validate_vpc_mode = regex("^$", (
    local.create_vpc && length(var.cluster_vswitchs_map) == 0
    ? "Must provide either vpc_id (existing VPC) or cluster_vswitchs_map (new VPC)"
    : ""
  ))

  // Resolve VPC and vSwitch IDs from whichever mode is configured
  resolved_vpc_id            = local.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  resolved_cluster_vswitch   = local.create_vpc ? module.vpc[0].public_vswitchs_ids_list[0] : var.cluster_vswitch_id
  resolved_mgmt_vswitch      = local.create_vpc ? module.vpc[0].management_vswitchs_ids_list[0] : var.mgmt_vswitch_id
  resolved_private_vswitch   = local.create_vpc ? module.vpc[0].private_vswitchs_ids_list[0] : var.private_vswitch_id

  // --- RAM Role ---
  create_ram_role = var.ram_role_name == "" ? 1 : 0

  // --- Cluster-specific token validations ---
  regex_token_valid = "(^https://(.+).checkpoint.com/app/maas/api/v1/tenant(.+)|^$)"

  split_tokenA  = split(" ", var.memberAToken)
  tokenA_decode = var.memberAToken != "" ? base64decode(element(local.split_tokenA, length(local.split_tokenA) - 1)) : ""
  // Will fail if memberAToken is non-empty and invalid
  validate_tokenA = var.memberAToken != "" ? (
    regex(local.regex_token_valid, local.tokenA_decode) == local.tokenA_decode ? 0 : "Smart-1 Cloud token A is invalid format"
  ) : 0

  split_tokenB  = split(" ", var.memberBToken)
  tokenB_decode = var.memberBToken != "" ? base64decode(element(local.split_tokenB, length(local.split_tokenB) - 1)) : ""
  // Will fail if memberBToken is non-empty and invalid
  validate_tokenB = var.memberBToken != "" ? (
    regex(local.regex_token_valid, local.tokenB_decode) == local.tokenB_decode ? 0 : "Smart-1 Cloud token B is invalid format"
  ) : 0

  // Will fail if exactly one of the two tokens is provided (both or neither is required)
  is_both_tokens_used         = length(var.memberAToken) > 0 == length(var.memberBToken) > 0
  validate_tokens_both_or_none = regex("^$", (local.is_both_tokens_used ? "" : "Both memberAToken and memberBToken must be provided together, or both left empty"))

  // Will fail if both tokens are provided but are identical (each member needs a unique token)
  is_tokens_used           = length(var.memberAToken) > 0
  is_both_tokens_the_same  = var.memberAToken == var.memberBToken
  validate_tokens_unique   = local.is_tokens_used ? regex("^$", (local.is_both_tokens_the_same ? "memberAToken and memberBToken must be unique — each cluster member requires a different token" : "")) : ""
}
