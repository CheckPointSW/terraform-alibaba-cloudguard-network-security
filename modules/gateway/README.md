# Check Point CloudGuard Security Gateway Terraform Module for Alibaba Cloud

Terraform module which deploys a Check Point Security Gateway on Alibaba Cloud. It supports deploying into an **existing VPC** or creating a **new VPC** automatically.

## Resources Deployed

- [Security Group](https://www.terraform.io/docs/providers/alicloud/r/security_group.html)
- [Network Interface](https://www.terraform.io/docs/providers/alicloud/r/network_interface.html) - internal ENI (eth1)
- [EIP](https://www.terraform.io/docs/providers/alicloud/r/eip.html) - conditional creation
- [Route Entry](https://www.terraform.io/docs/providers/alicloud/r/route_entry.html) - internal default route (conditional creation)
- [ECS Instance](https://www.terraform.io/docs/providers/alicloud/r/instance.html) - Security Gateway

## Note

- Make sure your region and zone support the required ECS instance types:
  [Alicloud Instance Types by Region](https://ecs-buy.aliyun.com/instanceTypes/?spm=a2c63.p38356.879954.139.1eeb2d44eZQw2m#/instanceTypeByRegion)

## Usage

```hcl
module "cloudguard_gateway" {
  source = "./modules/gateway"

  # --- VPC Network Configuration (new VPC) ---
  vpc_name             = "cp-vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_vswitchs_map  = { "us-east-1a" = 1 }
  private_vswitchs_map = { "us-east-1a" = 2 }
  vswitchs_bit_length  = 8

  # --- ECS Instance Configuration ---
  gateway_name               = "Check-Point-Gateway-tf"
  gateway_instance_type      = "ecs.g5ne.xlarge"
  key_name                   = "my-key-pair"
  allocate_and_associate_eip = true
  volume_size                = 100
  disk_category              = "cloud_efficiency"
  ram_role_name              = ""

  # --- Check Point Settings ---
  gateway_version       = "R81.20-BYOL"
  admin_shell           = "/etc/cli.sh"
  gateway_SICKey        = "myS1cKey123"
  gateway_password_hash = ""
  gateway_TokenKey      = ""

  # --- Advanced Settings (optional) ---
  resources_tag_name       = ""
  gateway_hostname         = ""
  allow_upload_download    = true
  gateway_bootstrap_script = ""
}
```

### Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply
```

## VPC

The module uses `vpc_id` to decide how to deploy:

- **New VPC** (default) — leave `vpc_id` empty. The module creates a VPC and vSwitches automatically from `vpc_cidr` and the vSwitch maps.
- **Existing VPC** — set `vpc_id` and the required vSwitch IDs to deploy into infrastructure you already manage.

```hcl
# Existing VPC example
module "cloudguard_gateway" {
  source = "./modules/gateway"

  vpc_id              = "vpc-xxxxxxxxxxxx"
  public_vswitch_id   = "vsw-xxxxxxxxxxxx"
  private_vswitch_id  = "vsw-xxxxxxxxxxxx"
  private_route_table = "vtb-xxxxxxxxxxxx"
  # ...
}
```

### Route table and default route

- **New VPC** — When you create a new VPC (`vpc_id` empty), the module always creates a private route table, attaches it to the private vSwitch, and adds a `0.0.0.0/0` default route via the gateway's internal ENI.
- **Existing VPC** — When you use an existing VPC, the module does not create a route table. The `0.0.0.0/0` default route is added only if you set `private_route_table` to an existing route table ID. If `private_route_table` is left empty, no default route is created and you must configure routing yourself.

## VSwitches

This module deploys the gateway with two network interfaces:

- **eth0 (public)** — attached to `public_vswitch_id`. This is the gateway's external interface and receives the EIP (if enabled).
- **eth1 (internal)** — attached to `private_vswitch_id`. This is the gateway's internal interface used to route traffic from private subnets.

## Conditional Creation

**Elastic IP (EIP)** — allocates and associates a public IP to the gateway:
```hcl
allocate_and_associate_eip = true
```

## Variables

| Name | Description | Type | Allowed Values | Default | Required |
|------|-------------|------|----------------|---------|----------|
| vpc_id | ID of an existing VPC. Leave empty or unset to create a new VPC | string | n/a | `""` | no |
| public_vswitch_id | Existing public vSwitch ID (eth0). Required when using an existing VPC | string | n/a | `""` | no |
| private_vswitch_id | Existing private vSwitch ID (eth1). Required when using an existing VPC | string | n/a | `""` | no |
| private_route_table | Route table ID in which to create the internal default route. Leave empty to skip | string | n/a | `""` | no |
| vpc_name | Name for the new VPC. Used only when creating a new VPC | string | n/a | `"cp-vpc"` | no |
| vpc_cidr | CIDR block for the new VPC | string | n/a | `"10.0.0.0/16"` | no |
| public_vswitchs_map | Map of `{zone = suffix}` for public vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| private_vswitchs_map | Map of `{zone = suffix}` for private vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| vswitchs_bit_length | Bits to extend vpc_cidr per subnet (e.g. `/16` + `8` = `/24`) | number | n/a | `8` | no |
| gateway_name | Name tag for the Security Gateway ECS instance | string | n/a | `"Check-Point-Gateway-tf"` | no |
| gateway_instance_type | ECS instance type for the Security Gateway | string | ecs.g5ne.large, ecs.g5ne.xlarge, ecs.g5ne.2xlarge, ecs.g5ne.4xlarge, ecs.g5ne.8xlarge, ecs.g7ne.large, ecs.g7ne.xlarge, ecs.g7ne.2xlarge, ecs.g7ne.4xlarge, ecs.g7ne.8xlarge | `"ecs.g5ne.xlarge"` | no |
| key_name | Name of the ECS Key Pair for SSH access | string | n/a | n/a | yes |
| allocate_and_associate_eip | When `true`, an Elastic IP is allocated and associated with the gateway | bool | true / false | `true` | no |
| volume_size | Root volume size in GB (minimum 100) | number | >= 100 | `100` | no |
| disk_category | ECS disk category | string | cloud, cloud_efficiency, cloud_ssd, cloud_essd | `"cloud_efficiency"` | no |
| ram_role_name | Predefined RAM role name to attach to the gateway instance | string | n/a | `""` | no |
| instance_tags | Map of tags to apply to the gateway ECS instance | map(string) | n/a | `{}` | no |
| gateway_version | Gateway version and license | string | R81-BYOL, R81.10-BYOL, R81.20-BYOL | `"R81.20-BYOL"` | no |
| admin_shell | Admin shell for advanced CLI configuration | string | /etc/cli.sh, /bin/bash, /bin/csh, /bin/tcsh | `"/etc/cli.sh"` | no |
| gateway_SICKey | Secure Internal Communication (SIC) key. Minimum 8 alphanumeric characters | string | n/a | n/a | yes |
| gateway_password_hash | Admin user password hash. Generate with: `openssl passwd -6 PASSWORD` | string | n/a | `""` | no |
| gateway_TokenKey | Smart-1 Cloud token for quick connect (SK180501) | string | n/a | `""` | no |
| resources_tag_name | Optional prefix applied to resource name tags | string | n/a | `""` | no |
| gateway_hostname | Optional hostname for the gateway | string | n/a | `""` | no |
| allow_upload_download | Allow automatic download of Blade Contracts and telemetry data to Check Point | bool | true / false | `true` | no |
| gateway_bootstrap_script | Optional semicolon-separated commands to run on first boot | string | n/a | `""` | no |
| primary_ntp | IPv4 address of the primary NTP server | string | n/a | `"ntp.cloud.aliyuncs.com"` | no |
| secondary_ntp | IPv4 address of the secondary NTP server | string | n/a | `"ntp7.cloud.aliyuncs.com"` | no |

## Outputs

### Adding Outputs to Your Configuration

```hcl
output "gateway_public_ip" {
  value = module.cloudguard_gateway.gateway_public_ip
}
```

### Available Outputs

| Name | Description |
|------|-------------|
| image_id | The image ID used for the deployed Security Gateway |
| permissive_sg_id | The permissive security group ID |
| permissive_sg_name | The permissive security group name |
| gateway_eip_id | The Elastic IP allocation ID |
| gateway_eip_public_ip | The public Elastic IP address |
| gateway_instance_id | The Security Gateway ECS instance ID |
| gateway_instance_name | The Security Gateway ECS instance name |
| internal_eni_id | The ID of the gateway's internal (eth1) ENI |
| vpc_id | The VPC ID (existing or newly created) |
