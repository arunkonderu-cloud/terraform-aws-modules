# Module: vpc

Production-grade AWS VPC with multi-AZ public/private subnets, NAT gateways, VPC flow logs, and security hardening defaults.

## Features

- Multi-AZ public and private subnets
- One NAT Gateway per AZ (high availability)
- VPC Flow Logs to CloudWatch (network audit trail)
- Default security group locked down (no implicit access)
- EKS-compatible subnet tagging out of the box
- Input validation on CIDR blocks and AZ count

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "prod-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = true
  enable_vpc_flow_logs    = true
  flow_log_retention_days = 30

  tags = {
    Environment = "prod"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for all resources | string | — | yes |
| cidr | VPC CIDR block | string | 10.0.0.0/16 | no |
| availability_zones | List of AZs (minimum 2) | list(string) | — | yes |
| public_subnets | Public subnet CIDRs | list(string) | [] | no |
| private_subnets | Private subnet CIDRs | list(string) | [] | no |
| enable_nat_gateway | Enable NAT Gateway per AZ | bool | true | no |
| enable_vpc_flow_logs | Enable flow logs to CloudWatch | bool | true | no |
| flow_log_retention_days | Log retention in days | number | 30 | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_public_ips | Public IPs for NAT Gateways |
| internet_gateway_id | Internet Gateway ID |
| flow_log_group_name | CloudWatch Log Group for flow logs |

## Security Defaults

- Public subnets do **not** auto-assign public IPs
- Default VPC security group has **zero** ingress/egress rules
- VPC flow logs capture **ALL** traffic (not just rejected)
- Flow log IAM role follows least-privilege principle
