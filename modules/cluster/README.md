# Check Point CloudGuard HA Cluster Terraform Module for Alibaba Cloud

Terraform module which deploys a Check Point CloudGuard High Availability Cluster into an Alibaba Cloud VPC. It supports deploying into an **existing VPC** or creating a **new VPC** automatically.

## Resources Deployed

- [Security Group](https://www.terraform.io/docs/providers/alicloud/r/security_group.html)
- [Network Interfaces](https://www.terraform.io/docs/providers/alicloud/r/network_interface.html) - cluster, management, and internal ENIs per member
- [EIPs](https://www.terraform.io/docs/providers/alicloud/r/eip.html) - cluster VIP, member management IPs (conditional creation)
- [Route Entry](https://www.terraform.io/docs/providers/alicloud/r/route_entry.html) - internal default route (conditional creation)
- [ECS Instances](https://www.terraform.io/docs/providers/alicloud/r/instance.html) - Member A and Member B
- [RAM Role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_role) - required for cluster failover

## Note

- Make sure your region and zone support the required ECS instance types:
  [Alicloud Instance Types by Region](https://ecs-buy.aliyun.com/instanceTypes/?spm=a2c63.p38356.879954.139.1eeb2d44eZQw2m#/instanceTypeByRegion)
- All three vSwitches (cluster, management, private) must be in the **same availability zone**.

## Usage

```hcl
module "cloudguard_cluster" {
  source = "./modules/cluster"

  # --- VPC Network Configuration (new VPC) ---
  vpc_name                = "cp-cluster-vpc"
  vpc_cidr                = "10.0.0.0/16"
  cluster_vswitchs_map    = { "us-east-1a" = 1 }
  management_vswitchs_map = { "us-east-1a" = 2 }
  private_vswitchs_map    = { "us-east-1a" = 3 }
  vswitchs_bit_length     = 8

  # --- ECS Instance Configuration ---
  gateway_name               = "Check-Point-Cluster-tf"
  gateway_instance_type      = "ecs.g5ne.xlarge"
  key_name                   = "my-key-pair"
  allocate_and_associate_eip = true
  volume_size                = 200
  disk_category              = "cloud_efficiency"
  ram_role_name              = ""

  # --- Check Point Settings ---
  gateway_version       = "R81.20-BYOL"
  admin_shell           = "/etc/cli.sh"
  gateway_SICKey        = "myS1cKey123"
  gateway_password_hash = ""
  memberAToken          = ""
  memberBToken          = ""

  # --- Advanced Settings (optional) ---
  management_ip_address    = ""
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
module "cloudguard_cluster" {
  source = "./modules/cluster"

  vpc_id              = "vpc-xxxxxxxxxxxx"
  cluster_vswitch_id  = "vsw-xxxxxxxxxxxx"
  mgmt_vswitch_id     = "vsw-xxxxxxxxxxxx"
  private_vswitch_id  = "vsw-xxxxxxxxxxxx"
  private_route_table = "vtb-xxxxxxxxxxxx"
  # ...
}
```

### Route table and default route

- **New VPC** — When you create a new VPC (`vpc_id` empty), the module always creates a private route table, attaches it to the private vSwitch, and adds a `0.0.0.0/0` default route via the active member's internal ENI.
- **Existing VPC** — When you use an existing VPC, the module does not create a route table. The `0.0.0.0/0` default route is added only if you set `private_route_table` to an existing route table ID. If `private_route_table` is left empty, no default route is created and you must configure routing yourself.

## VSwitches

This module requires three VSwitches, all in the **same availability zone**:

| Variable | Interface | Purpose |
|----------|-----------|---------|
| `cluster_vswitch_id` | eth0 (external) | Carries the cluster floating VIP. Internet-facing traffic enters and exits here |
| `mgmt_vswitch_id` | eth1 (management) | Used for management connectivity — SmartConsole, SIC, and SSH access to each member |
| `private_vswitch_id` | eth2 (internal) | Internal LAN traffic routed through the active cluster member |

## Conditional Creation

**Elastic IPs** — allocates EIPs for the cluster VIP and each member's management interface:
```hcl
allocate_and_associate_eip = true
```

**Internal Default Route** — creates a `0.0.0.0/0` route in the specified route table pointing to the active member's internal ENI. The route table must not already have a `0.0.0.0/0` route:
```hcl
private_route_table = "vtb-xxxxxxxxxxxx"
```

**Management Static Route** — if `management_ip_address` is provided, a static route to the Management Server via eth1 is automatically configured on both members:
```hcl
management_ip_address = "1.2.3.4"
```

**RAM Role** — a RAM role with the required Alibaba Cloud API permissions for cluster failover is created automatically when `ram_role_name` is left empty. To use a predefined role, provide its name.

## Variables

| Name | Description | Type | Allowed Values | Default | Required |
|------|-------------|------|----------------|---------|----------|
| vpc_id | ID of an existing VPC. Leave empty or unset to create a new VPC | string | n/a | `""` | no |
| cluster_vswitch_id | Existing cluster vSwitch ID (eth0 — floating VIP). Required when using an existing VPC | string | n/a | `""` | no |
| mgmt_vswitch_id | Existing management vSwitch ID (eth1 — SmartConsole/SSH). Required when using an existing VPC | string | n/a | `""` | no |
| private_vswitch_id | Existing private vSwitch ID (eth2 — LAN). Required when using an existing VPC | string | n/a | `""` | no |
| private_route_table | Route table ID for the internal default route. Leave empty to skip | string | n/a | `""` | no |
| vpc_name | Name for the new VPC. Used only when creating a new VPC | string | n/a | `"cp-vpc"` | no |
| vpc_cidr | CIDR block for the new VPC | string | n/a | `"10.0.0.0/16"` | no |
| cluster_vswitchs_map | Map of `{zone = suffix}` for cluster vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| management_vswitchs_map | Map of `{zone = suffix}` for management vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| private_vswitchs_map | Map of `{zone = suffix}` for private vSwitches. Required when creating a new VPC | map(string) | n/a | `{}` | no |
| vswitchs_bit_length | Bits to extend vpc_cidr per subnet (e.g. `/16` + `8` = `/24`) | number | n/a | `8` | no |
| gateway_name | Name tag prefix for the cluster member ECS instances | string | n/a | `"Check-Point-Cluster-tf"` | no |
| gateway_instance_type | ECS instance type for the cluster members | string | ecs.g5ne.large, ecs.g5ne.xlarge, ecs.g5ne.2xlarge, ecs.g5ne.4xlarge, ecs.g5ne.8xlarge, ecs.g7ne.large, ecs.g7ne.xlarge, ecs.g7ne.2xlarge, ecs.g7ne.4xlarge, ecs.g7ne.8xlarge | `"ecs.g5ne.xlarge"` | no |
| key_name | Name of the ECS Key Pair for SSH access to both cluster members | string | n/a | n/a | yes |
| allocate_and_associate_eip | When `true`, EIPs are allocated for the cluster VIP and each member's management interface | bool | true / false | `true` | no |
| volume_size | Root volume size in GB (minimum 100) | number | >= 100 | `200` | no |
| disk_category | ECS disk category | string | cloud, cloud_efficiency, cloud_ssd, cloud_essd | `"cloud_efficiency"` | no |
| ram_role_name | Predefined RAM role name. If empty, a new role is created automatically | string | n/a | `""` | no |
| instance_tags | Map of tags to apply to the cluster member ECS instances | map(string) | n/a | `{}` | no |
| gateway_version | Gateway version and license | string | R81-BYOL, R81.10-BYOL, R81.20-BYOL | `"R81.20-BYOL"` | no |
| admin_shell | Admin shell for advanced CLI configuration | string | /etc/cli.sh, /bin/bash, /bin/csh, /bin/tcsh | `"/etc/cli.sh"` | no |
| gateway_SICKey | Secure Internal Communication (SIC) key. Minimum 8 alphanumeric characters | string | n/a | n/a | yes |
| gateway_password_hash | Admin user password hash. Generate with: `openssl passwd -6 PASSWORD` | string | n/a | `""` | no |
| memberAToken | Smart-1 Cloud token for Member A (SK180501). Must differ from memberBToken | string | n/a | `""` | no |
| memberBToken | Smart-1 Cloud token for Member B (SK180501). Must differ from memberAToken | string | n/a | `""` | no |
| management_ip_address | Public or private IP of the Security Management Server. If provided, a static route to this IP via eth1 is added automatically | string | n/a | `""` | no |
| resources_tag_name | Optional prefix applied to resource name tags | string | n/a | `""` | no |
| gateway_hostname | Optional base hostname — appended with `-member-a` and `-member-b` for each member | string | n/a | `""` | no |
| allow_upload_download | Allow automatic download of Blade Contracts and telemetry data to Check Point | bool | true / false | `true` | no |
| gateway_bootstrap_script | Optional semicolon-separated commands to run on first boot | string | n/a | `""` | no |
| primary_ntp | IPv4 address of the primary NTP server | string | n/a | `"ntp.cloud.aliyuncs.com"` | no |
| secondary_ntp | IPv4 address of the secondary NTP server | string | n/a | `"ntp7.cloud.aliyuncs.com"` | no |

## Outputs

### Adding Outputs to Your Configuration

```hcl
output "cluster_vip" {
  value = module.cloudguard_cluster.cluster_primary_eip
}
```

### Available Outputs

| Name | Description |
|------|-------------|
| cluster_primary_eip | The cluster floating VIP (primary Elastic IP) |
| cluster_secondary_eip | The cluster secondary Elastic IP |
| member_a_eip | Member A management Elastic IP |
| member_b_eip | Member B management Elastic IP |
| member_a_instance_id | Member A ECS instance ID |
| member_b_instance_id | Member B ECS instance ID |
| member_a_instance_name | Member A ECS instance name |
| member_b_instance_name | Member B ECS instance name |
| member_a_internal_eni_id | Internal ENI ID of Member A |
| permissive_sg_id | The permissive security group ID |
| permissive_sg_name | The permissive security group name |
| image_id | The image ID used for the deployed cluster members |
| vpc_id | The VPC ID (existing or newly created) |
