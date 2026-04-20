# Check Point CloudGuard Management Server Terraform Module for Alibaba Cloud

Terraform module which deploys a Check Point Management Server on Alibaba Cloud. It supports deploying into an **existing VPC** or creating a **new VPC** automatically.

## Resources Deployed

- [ECS Instance](https://www.terraform.io/docs/providers/alicloud/r/instance.html) - Management Server
- [Security Group](https://www.terraform.io/docs/providers/alicloud/r/security_group.html)
- [EIP](https://www.terraform.io/docs/providers/alicloud/r/eip.html) - conditional creation

## Note

- Make sure your region and zone support the required ECS instance types:
  [Alicloud Instance Types by Region](https://ecs-buy.aliyun.com/instanceTypes/?spm=a2c63.p38356.879954.139.1eeb2d44eZQw2m#/instanceTypeByRegion)
- Finalizing configuration may take up to 20 minutes after deployment completes.

## Usage

```hcl
module "cloudguard_management" {
  source = "./modules/management"

  # --- VPC Network Configuration (new VPC) ---
  vpc_name            = "cp-mgmt-vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_vswitchs_map = { "us-east-1a" = 1 }
  vswitchs_bit_length = 8

  # --- ECS Instance Configuration ---
  instance_name              = "CP-Management-tf"
  instance_type              = "ecs.g6e.xlarge"
  key_name                   = "my-key-pair"
  allocate_and_associate_eip = true
  volume_size                = 200
  disk_category              = "cloud_essd"
  ram_role_name              = ""

  # --- Check Point Settings ---
  version_license       = "R81.20-BYOL"
  admin_shell           = "/etc/cli.sh"
  password_hash         = ""
  hostname              = ""

  # --- Security Management Server Settings ---
  is_primary_management = true
  SICKey                = ""
  allow_upload_download = true
  gateway_management    = "Over the internet"
  admin_cidr            = "0.0.0.0/0"
  gateway_addresses     = "0.0.0.0/0"

  # --- Advanced Settings (optional) ---
  bootstrap_script = ""
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

- **New VPC** (default) — leave `vpc_id` empty. The module creates a VPC and a vSwitch automatically from `vpc_cidr` and `public_vswitchs_map`.
- **Existing VPC** — set `vpc_id` and `vswitch_id` to deploy into infrastructure you already manage.

```hcl
# Existing VPC example
module "cloudguard_management" {
  source = "./modules/management"

  vpc_id     = "vpc-xxxxxxxxxxxx"
  vswitch_id = "vsw-xxxxxxxxxxxx"
  # ...
}
```

## Access Control

Two CIDR-based variables control who can reach the Management Server:

- **`admin_cidr`** — restricts web UI, SSH, and SmartConsole access to the specified IP range (e.g. your office IP: `203.0.113.0/24`).
- **`gateway_addresses`** — restricts which gateway IPs are allowed to communicate with the Management Server for SIC and policy push.

## Gateway Management Mode

The `gateway_management` variable controls how the Management Server reaches the gateways it manages:

- **`"Over the internet"`** — use this when gateways are deployed in a different network or region and are not reachable via private IP. The Management Server will use the gateways' public IPs for SIC and policy installation. This is the recommended setting for most cloud deployments.
- **`"Locally managed"`** — use this only when all gateways are reachable via private IP within the same VPC or a directly connected network.

## Variables

| Name | Description | Type | Allowed Values | Default | Required |
|------|-------------|------|----------------|---------|----------|
| vpc_id | ID of an existing VPC. Leave empty or unset to create a new VPC | string | n/a | `""` | no |
| vswitch_id | Existing vSwitch ID for the Management Server. Required when using an existing VPC | string | n/a | `""` | no |
| vpc_name | Name for the new VPC. Used only when creating a new VPC | string | n/a | `"cp-vpc"` | no |
| vpc_cidr | CIDR block for the new VPC | string | n/a | `"10.0.0.0/16"` | no |
| public_vswitchs_map | Map of `{zone = suffix}` for vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| vswitchs_bit_length | Bits to extend vpc_cidr per subnet (e.g. `/16` + `8` = `/24`) | number | n/a | `8` | no |
| instance_name | ECS instance name for the Management Server | string | n/a | `"CP-Management-tf"` | no |
| instance_type | ECS instance type for the Management Server | string | ecs.g6e.large, ecs.g6e.xlarge, ecs.g6e.2xlarge, ecs.g6e.4xlarge, ecs.g6e.8xlarge | `"ecs.g6e.xlarge"` | no |
| key_name | Name of the ECS Key Pair for SSH access | string | n/a | n/a | yes |
| allocate_and_associate_eip | When `true`, an Elastic IP is allocated and associated with the Management Server | bool | true / false | `true` | no |
| volume_size | Root volume size in GB (minimum 100) | number | >= 100 | `200` | no |
| disk_category | ECS disk category | string | cloud, cloud_efficiency, cloud_ssd, cloud_essd | `"cloud_essd"` | no |
| ram_role_name | Predefined RAM role name to attach to the Management Server instance | string | n/a | `""` | no |
| instance_tags | Map of tags to apply to the Management Server ECS instance | map(string) | n/a | `{}` | no |
| version_license | Management Server version and license | string | R81-BYOL, R81.10-BYOL, R81.20-BYOL | `"R81.20-BYOL"` | no |
| admin_shell | Admin shell for advanced CLI configuration | string | /etc/cli.sh, /bin/bash, /bin/csh, /bin/tcsh | `"/etc/cli.sh"` | no |
| password_hash | Admin user password hash. Generate with: `openssl passwd -6 PASSWORD` | string | n/a | `""` | no |
| hostname | Optional hostname for the Management Server | string | n/a | `""` | no |
| is_primary_management | Set to `true` for a Primary Management Server, `false` for a Secondary | bool | true / false | `true` | no |
| SICKey | SIC key — required only when deploying a Secondary Management Server. Minimum 8 alphanumeric characters | string | n/a | `""` | no |
| allow_upload_download | Allow automatic download of Blade Contracts and telemetry data to Check Point | bool | true / false | `true` | no |
| gateway_management | How the Management Server connects to gateways | string | Locally managed, Over the internet | `"Locally managed"` | no |
| admin_cidr | CIDR block that is allowed to access the Management Server via web UI, SSH, and SmartConsole | string | valid CIDR | n/a | yes |
| gateway_addresses | CIDR block from which gateways are allowed to communicate with the Management Server | string | valid CIDR | n/a | yes |
| primary_ntp | IPv4 address of the primary NTP server | string | n/a | `"ntp.cloud.aliyuncs.com"` | no |
| secondary_ntp | IPv4 address of the secondary NTP server | string | n/a | `"ntp7.cloud.aliyuncs.com"` | no |
| bootstrap_script | Optional semicolon-separated commands to run on first boot | string | n/a | `""` | no |

## Outputs

### Adding Outputs to Your Configuration

```hcl
output "management_public_ip" {
  value = module.cloudguard_management.management_public_ip
}
```

### Available Outputs

| Name | Description |
|------|-------------|
| image_id | The image ID used for the deployed Management Server |
| management_instance_id | The Management Server ECS instance ID |
| management_instance_name | The Management Server ECS instance name |
| management_instance_tags | The tags applied to the Management Server ECS instance |
| management_public_ip | The public Elastic IP address of the Management Server (empty if EIP not allocated) |
| vpc_id | The VPC ID (existing or newly created) |
