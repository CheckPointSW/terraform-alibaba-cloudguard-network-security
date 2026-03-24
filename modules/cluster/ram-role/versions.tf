terraform {
  required_version = ">= 0.14.3"
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.213.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
