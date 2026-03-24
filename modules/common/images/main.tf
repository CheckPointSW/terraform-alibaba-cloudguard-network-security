data "alicloud_regions" "current" {
  current = true
}

locals {
  region = data.alicloud_regions.current.regions.0.id

  images_yaml_regionMap    = yamldecode(split("Resources", file("${path.module}/images.yaml"))[0]).Mappings.RegionMap
  images_yaml_converterMap = yamldecode(split("Resources", file("${path.module}/images.yaml"))[0]).Mappings.ConverterMap

  version_license_key   = format("%s%s", var.version_license, var.chkp_type == "gateway" ? "-GW" : var.chkp_type == "management" ? "-MGMT" : "")
  version_license_value = local.images_yaml_converterMap[local.version_license_key]["Value"]
  image_id              = local.images_yaml_regionMap[local.region][local.version_license_value]
}
