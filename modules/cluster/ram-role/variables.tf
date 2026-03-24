variable "gateway_name" {
  type        = string
  description = "Gateway name used to prefix the RAM role and policy names"
  default     = "tf-cluster"
}
