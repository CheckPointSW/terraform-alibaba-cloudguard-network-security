![GitHub Watchers](https://img.shields.io/github/watchers/CheckPointSW/terraform-alibaba-cloudguard-network-security)
![GitHub Release](https://img.shields.io/github/v/release/CheckPointSW/terraform-alibaba-cloudguard-network-security)
![GitHub Commits Since Last Commit](https://img.shields.io/github/commits-since/CheckPointSW/terraform-alibaba-cloudguard-network-security/latest/master)
![GitHub Last Commit](https://img.shields.io/github/last-commit/CheckPointSW/terraform-alibaba-cloudguard-network-security/master)
![GitHub Repo Size](https://img.shields.io/github/repo-size/CheckPointSW/terraform-alibaba-cloudguard-network-security)
![GitHub Downloads](https://img.shields.io/github/downloads/CheckPointSW/terraform-alibaba-cloudguard-network-security/total)

# Terraform Modules for CloudGuard Network Security (CGNS) - Alibaba Cloud

## Introduction

This repository provides a structured set of Terraform modules for deploying Check Point CloudGuard Network Security on Alibaba Cloud. These modules automate the creation of VPCs, VSwitches, Security Gateways, High-Availability Cluster architectures, and Management Servers, enabling secure and scalable cloud deployments.

## Before You Begin

- Create an [Alibaba Cloud account](https://www.alibabacloud.com/) and ensure billing is set up.
- [Install Terraform](https://developer.hashicorp.com/terraform/downloads) (version >= 1.0 recommended).
- Make sure your region and zone support the required ECS instance types:
  [Alicloud Instance Types by Region](https://ecs-buy.aliyun.com/instanceTypes/?spm=a2c63.p38356.879954.139.1eeb2d44eZQw2m#/instanceTypeByRegion)

## Configuring the Provider

Best practice is to configure credentials using environment variables. See the [Alicloud provider documentation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs) for details.

**Linux / macOS:**
```bash
export ALICLOUD_ACCESS_KEY=anaccesskey
export ALICLOUD_SECRET_KEY=asecretkey
export ALICLOUD_REGION=us-east-1
```

**Windows:**
```cmd
set ALICLOUD_ACCESS_KEY=anaccesskey
set ALICLOUD_SECRET_KEY=asecretkey
set ALICLOUD_REGION=us-east-1
```

## Repository Structure

**Solution Modules** — use these directly in your `main.tf`:

| Module | Description |
|--------|-------------|
| [`gateway`](modules/gateway/) | Deploys a CloudGuard Security Gateway (new or existing VPC) |
| [`management`](modules/management/) | Deploys a CloudGuard Management Server (new or existing VPC) |
| [`cluster`](modules/cluster/) | Deploys a CloudGuard HA Cluster (new or existing VPC) |

Each module supports two modes controlled by the `vpc_id` variable:
- **New VPC** — leave `vpc_id` empty and provide vSwitch CIDR maps; the module creates the VPC, VSwitches, and route tables automatically.
- **Existing VPC** — set `vpc_id` and the required vSwitch IDs to deploy into infrastructure you already manage.

**Internal Submodules** — used internally by the solution modules above:

| Module | Description |
|--------|-------------|
| [`common/vpc`](modules/common/vpc/) | Creates a VPC and VSwitches |
| [`common/images`](modules/common/images/) | Looks up the correct Check Point image by region and version |
| [`common/validations`](modules/common/validations/) | Validates inputs (instance type, version, SIC key, etc.) |
| [`common/permissive-sg`](modules/common/permissive-sg/) | Creates a permissive security group |
| [`common/elastic-ip`](modules/common/elastic-ip/) | Allocates and associates an Elastic IP |
| [`common/internal-default-route`](modules/common/internal-default-route/) | Adds a default route through an internal ENI |

## Usage

### Step 1: Add the Module to Your main.tf

```hcl
module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/alibaba//modules/{module_name}"
  version = "{chosen_version}"
  # Add the required inputs
}
```

Fill all required variables. See each module's README for the full variable reference and a complete `main.tf` example.

### Step 2: Deploy with Terraform

**Initialize** — download required provider plugins:
```bash
terraform init
```

**Plan** — preview the changes Terraform will make:
```bash
terraform plan
```

**Apply** — deploy the resources:
```bash
terraform apply
```
