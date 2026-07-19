# Check Point CloudGuard GWLB Terraform Module for Alibaba Cloud

Terraform module which deploys a Check Point Cloud Firewall solution on Alibaba Cloud using **Gateway Load Balancer (GWLB)**. It provisions the security-side infrastructure: a security VPC, a multi-zone ESS auto-scaling group of Check Point NVA instances, a GWLB with a server group, and a PrivateLink endpoint service for the customer to attach their business VPC.

The module supports deploying into an **existing VPC** or creating a **new security VPC** automatically.

## Prerequisites

- Minimum CME take on the Security Management Server: **325** or higher.
- The RAM user or role used to deploy this module must have the following actions allowed:

<details>
<summary><b>Required RAM Permissions</b></summary>
<br>

```
ecs:CreateSecurityGroup
ecs:DeleteSecurityGroup
ecs:DescribeSecurityGroups
ecs:AuthorizeSecurityGroup
ecs:AuthorizeSecurityGroupEgress
ecs:RevokeSecurityGroup
ecs:RevokeSecurityGroupEgress
ecs:DescribeSecurityGroupAttribute
ecs:DescribeImages
ecs:DescribeInstanceTypes
ecs:DescribeRegions
ecs:DescribeZones
ess:CreateScalingGroup
ess:ModifyScalingGroup
ess:DeleteScalingGroup
ess:DescribeScalingGroups
ess:CreateScalingConfiguration
ess:ModifyScalingConfiguration
ess:DeleteScalingConfiguration
ess:DescribeScalingConfigurations
ess:EnableScalingGroup
ess:DisableScalingGroup
ess:CreateScalingRule
ess:ModifyScalingRule
ess:DeleteScalingRule
ess:DescribeScalingRules
ess:AttachLoadBalancers
ess:DetachLoadBalancers
ess:AttachServerGroups
ess:DetachServerGroups
gwlb:CreateLoadBalancer
gwlb:DeleteLoadBalancer
gwlb:UpdateLoadBalancerAttribute
gwlb:ListLoadBalancers
gwlb:GetLoadBalancerAttribute
gwlb:CreateServerGroup
gwlb:DeleteServerGroup
gwlb:UpdateServerGroupAttribute
gwlb:ListServerGroups
gwlb:GetServerGroupAttribute
gwlb:AddServersToServerGroup
gwlb:RemoveServersFromServerGroup
gwlb:CreateListener
gwlb:DeleteListener
gwlb:UpdateListenerAttribute
gwlb:ListListeners
privatelink:CreateVpcEndpointService
privatelink:DeleteVpcEndpointService
privatelink:UpdateVpcEndpointServiceAttribute
privatelink:GetVpcEndpointServiceAttribute
privatelink:ListVpcEndpointServices
privatelink:AttachResourceToVpcEndpointService
privatelink:DetachResourceFromVpcEndpointService
privatelink:AddUserToVpcEndpointService
privatelink:RemoveUserFromVpcEndpointService
ram:PassRole
vpc:CreateVpc
vpc:DeleteVpc
vpc:DescribeVpcs
vpc:CreateVSwitch
vpc:DeleteVSwitch
vpc:DescribeVSwitches
vpc:CreateRouteEntry
vpc:DeleteRouteEntry
vpc:DescribeRouteTables
```

</details>

## Architecture

![GWLB Architecture](https://raw.githubusercontent.com/CheckPointSW/terraform-alibaba-cloudguard-network-security/master/modules/gwlb/gwlb-architecture.png)

Traffic flows from the customer Business VPC through a GWLB endpoint (GWLBe) over PrivateLink to the Check Point Security VPC, where the multi-zone Gateway Load Balancer distributes it across the auto-scaling group of NVA instances for inspection.

## Resources Deployed

- [**VPC**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) + [**vSwitches**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) — security VPC with one vSwitch per availability zone (new VPC mode only)
- [**Security Group**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) + [**rules**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) — permissive security group for NVA instances
- [**ESS Scaling Group**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_group) + [**Configuration**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_configuration) — auto-scaling group of Check Point gateway instances
- [**ESS Scaling Rule**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ess_scaling_rule) — CPU-based target tracking rule
- [**GWLB Load Balancer**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/gwlb_load_balancer) — Gateway Load Balancer spanning all configured zones
- [**GWLB Server Group**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/gwlb_server_group) — instance-type server group with health check and connection draining
- [**GWLB Listener**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/gwlb_listener) — forwards all GENEVE traffic to the server group
- [**PrivateLink Endpoint Service**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/privatelink_vpc_endpoint_service) + [**Resource**](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/privatelink_vpc_endpoint_service_resource) — exposes the GWLB to customer business VPCs


## Usage

### New Security VPC (default)

```hcl
module "cloudguard_gwlb" {
  source  = "CheckPointSW/cloudguard-network-security/alibaba//modules/gwlb"
  version = "~> 1.0"

  # --- General ---
  prefix   = "cp-gwlb"
  key_name = "my-key-pair"

  # --- Security VPC ---
  security_vpc_cidr = "10.0.0.0/16"
  security_vswitchs_map = {
    "cn-hangzhou-j" = 1
    "cn-hangzhou-k" = 2
  }
  vswitchs_bit_length = 8

  # --- Check Point NVA ---
  gateway_instance_type = "ecs.g5ne.xlarge"
  gateway_version       = "R82-BYOL"
  gateway_SICKey           = "mySICkey123"
  gateway_password_hash    = ""
  gateway_bootstrap_script = ""
  admin_shell              = "/etc/cli.sh"
  volume_size           = 200
  disk_category         = "cloud_efficiency"
  allocate_public_ip    = true

  # --- Scale Set Sizing ---
  min_group_size   = 2
  max_group_size   = 10
  desired_capacity = 2
  cpu_usage        = 60

  # --- CME Auto-Provisioning ---
  management_name             = "my-mgmt"
  configuration_template_name = "my-template"

  # --- Common ---
  allow_upload_download = true
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

- **New VPC** (default) — leave `vpc_id` empty. The module creates a security VPC and one vSwitch per zone from `security_vpc_cidr` and `security_vswitchs_map`.
- **Existing VPC** — set `vpc_id` and provide `security_vswitchs_ids` with a list of existing vSwitch IDs (one per zone). The module looks up each vSwitch's zone automatically and skips VPC/vSwitch creation entirely.

### Existing Security VPC

Replace the `Security VPC` section in the example above with:

```hcl
  # --- Existing VPC ---
  vpc_id = "vpc-bp1xxxxxxxxxx"
  security_vswitchs_ids = [
    "vsw-bp1xxxxxxxxxx",
    "vsw-bp1yyyyyyyyyy",
  ]
```

## Multi-Zone

The module deploys across all zones defined in `security_vswitchs_map` (new VPC) or `security_vswitchs_ids` (existing VPC).

> **Supported zones** — not all availability zones support GWLB. Check the [Alibaba Cloud GWLB supported regions and zones](https://www.alibabacloud.com/help/en/slb/gateway-based-load-balancing-gwlb/product-overview/regions-and-zones-supported-by-gwlb) list before configuring zones. Unsupported zones will fail at apply time.

## Consumer-Side Setup (Business VPC)

This module deploys the **service provider** side (security VPC + GWLB + PrivateLink endpoint service). The customer must perform two steps in their own business VPC: (1) create a GWLB endpoint (GWLBe) that connects to the endpoint service, and (2) configure route tables so traffic flows through the GWLBe.

The example below assumes:
- Business VPC with an application server vSwitch (`192.168.2.0/24`) and a GWLBe vSwitch (`192.168.5.0/24`)
- IPv4 gateway attached to the business VPC for north-south traffic

### Step 1 — Create the GWLB endpoint

After `terraform apply`, take the `endpoint_service_id` output and use it in the Alibaba console:

1. Sign in to the [PrivateLink console](https://privatelink.console.aliyun.com/).
2. **Endpoints → Interface Endpoint → Create Endpoint**.
3. Fill in the form:

   | Field | Value |
   |-------|-------|
   | Region | Same region as the security VPC |
   | Endpoint Name | Any name |
   | Endpoint Type | **GWLB Endpoint** |
   | Endpoint Service | Click **Select Service** and pick the service identified by the module's `endpoint_service_id` output |
   | VPC | The **business VPC** (not the security VPC) |
   | Zones and vSwitches | Pick the AZ that matches the endpoint service, and the GWLBe vSwitch inside it. An ENI is created in that vSwitch automatically |
   | IP Version | IPv4 |

4. Wait until the endpoint **Connection Status** becomes **Connected**.

### Step 2 — Configure routes

Three route tables in the business VPC need to be updated. The examples use the CIDRs above.

#### Route table for the IPv4 gateway

Direct traffic destined for the application server to the GWLBe so that **inbound** traffic is inspected before reaching the workload.

| Destination CIDR | Next hop | Type |
|------------------|----------|------|
| 192.168.5.0/24 | Local | System |
| 192.168.2.0/24 | Gateway Load Balancer endpoint (GWLBe) | Custom |

> Modify the auto-created system route entry for the application server CIDR: change its next-hop to the GWLBe.

#### Route table for the application server vSwitch

Send **outbound** traffic from the application server to the GWLBe for inspection.

| Destination CIDR | Next hop | Type |
|------------------|----------|------|
| 192.168.2.0/24 | Local | System |
| 192.168.5.0/24 | Local | System |
| 0.0.0.0/0 | Gateway Load Balancer endpoint (GWLBe) | Custom |

#### Route table for the GWLBe vSwitch

Return traffic from the GWLBe out to the internet via the IPv4 gateway.

| Destination CIDR | Next hop | Type |
|------------------|----------|------|
| 192.168.2.0/24 | Local | System |
| 192.168.5.0/24 | Local | System |
| 0.0.0.0/0 | IPv4 gateway | Custom |

> The local routes ensure return traffic from the internet reaches the application server. The custom `0.0.0.0/0 → IPv4 gateway` route handles outbound traffic exiting after inspection.

## Variables

| Name | Description | Type | Allowed Values | Default | Required |
|------|-------------|------|----------------|---------|----------|
| prefix | Name prefix for all resources (e.g. `cp-gwlb` → `cp-gwlb-security-vpc`) | string | — | — | yes |
| vpc_id | Existing VPC ID. Leave empty to create a new security VPC | string | — | `""` | no |
| security_vpc_cidr | CIDR block for the new security VPC | string | — | `"10.0.0.0/16"` | no |
| security_vswitchs_map | Map of `{zone = cidr-suffix}` for new vSwitches. Required when `vpc_id` is empty | map(number) | — | `{}` | no |
| security_vswitchs_ids | List of existing vSwitch IDs. Zone is auto-detected. Required when `vpc_id` is set | list(string) | — | `[]` | no |
| vswitchs_bit_length | Bits to extend `security_vpc_cidr` per vSwitch (e.g. /16 + 8 = /24) | number | — | `8` | no |
| key_name | SSH key pair name for instance access | string | — | — | yes |
| gateway_instance_type | ECS instance type (g5ne or g7ne family) | string | `ecs.g5ne.large`, `ecs.g5ne.xlarge`, `ecs.g5ne.2xlarge`, `ecs.g5ne.4xlarge`, `ecs.g5ne.8xlarge`, `ecs.g7ne.large`, `ecs.g7ne.xlarge`, `ecs.g7ne.2xlarge`, `ecs.g7ne.4xlarge`, `ecs.g7ne.8xlarge` | `"ecs.g5ne.xlarge"` | no |
| gateway_version | Check Point version and license | string | `R81.20-BYOL`, `R82-BYOL`, `R82.10-BYOL` | `"R82-BYOL"` | no |
| gateway_SICKey | Secure Internal Communication key (min 8 alphanumeric chars) | string | — | — | yes |
| gateway_password_hash | Admin password hash. Generate with: `openssl passwd -6 PASSWORD` | string | — | `""` | no |
| admin_shell | Admin shell | string | `/etc/cli.sh`, `/bin/bash`, `/bin/csh`, `/bin/tcsh` | `"/etc/cli.sh"` | no |
| gateway_bootstrap_script | Optional semicolon-separated commands to run on first boot | string | — | `""` | no |
| volume_size | Root volume size in GB (minimum 100) | number | min `100` | `200` | no |
| disk_category | ECS disk category | string | `cloud_efficiency`, `cloud_ssd`, `cloud_essd` | `"cloud_efficiency"` | no |
| allocate_public_ip | Assign a public IP to each NVA instance | bool | `true`, `false` | `true` | no |
| gateway_internet_charge_type | Billing method for public IP traffic | string | `PayByTraffic`, `PayByBandwidth` | `"PayByTraffic"` | no |
| gateway_internet_max_bandwidth_out | Outbound public bandwidth in Mbit/s. Used when `allocate_public_ip = true` | number | `1`–`100` | `100` | no |
| min_group_size | Minimum number of NVA instances | number | min `1` | `2` | no |
| max_group_size | Maximum number of NVA instances | number | min `1` | `10` | no |
| desired_capacity | Initial number of NVA instances | number | min `1` | `2` | no |
| cpu_usage | Target CPU utilization % for auto-scaling | number | `1`–`100` | `60` | no |
| multi_az_policy | ESS multi-zone distribution policy | string | `PRIORITY`, `BALANCE` | `"BALANCE"` | no |
| connection_drain_timeout | Seconds to drain connections on scale-in | number | `1`–`3600` | `300` | no |
| management_name | CME management server name | string | — | `"mgmt"` | no |
| configuration_template_name | CME configuration template name | string | — | `"template"` | no |
| allow_upload_download | Allow Blade Contract and telemetry download | bool | `true`, `false` | `true` | no |
| primary_ntp | Primary NTP server | string | — | `"ntp.cloud.aliyuncs.com"` | no |
| secondary_ntp | Secondary NTP server | string | — | `"ntp7.cloud.aliyuncs.com"` | no |
| instance_tags | Additional tags for NVA instances | map(string) | — | `{}` | no |

## Outputs

### Adding Outputs to Your Configuration

```hcl
output "endpoint_service_id" {
  value = module.cloudguard_gwlb.endpoint_service_id
}
```

### Available Outputs

| Name | Description |
|------|-------------|
| security_vpc_id | Security VPC ID (created or existing) |
| security_vswitch_ids | Map of `{zone = vswitch-id}` for the security vSwitches |
| scaling_group_id | ESS scaling group ID |
| gwlb_id | GWLB load balancer ID |
| gwlb_server_group_id | GWLB server group ID |
| endpoint_service_id | PrivateLink endpoint service ID — provide this to the customer to create the GWLBe |
