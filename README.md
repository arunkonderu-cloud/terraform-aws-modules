# terraform-aws-modules

> Production-grade, reusable Terraform modules for AWS infrastructure provisioning.  
> Built to enforce consistency, security, and compliance across multi-account enterprise environments.

[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.5-blue)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Supported-orange)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/YOUR_USERNAME/terraform-aws-modules/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/terraform-aws-modules/actions)

---

## Overview

This repository provides a library of reusable, opinionated Terraform modules that abstract AWS complexity — enabling teams to provision infrastructure without requiring deep service-specific expertise.

Each module follows AWS Well-Architected Framework principles and is designed for:
- **Multi-account AWS environments** (dev / staging / prod isolation)
- **Security and compliance by default** (encryption, least-privilege IAM, VPC isolation)
- **CI/CD integration** (validated via GitHub Actions on every PR)
- **Enterprise-scale operations** (remote state, state locking, modular composition)

---

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| [vpc](./modules/vpc) | Production VPC with public/private subnets, NAT, flow logs | ✅ Stable |
| [eks](./modules/eks) | EKS cluster with managed node groups, IRSA, and add-ons | ✅ Stable |
| [rds](./modules/rds) | RDS (PostgreSQL/MySQL) with Multi-AZ, encryption, backups | ✅ Stable |
| [s3-secure](./modules/s3-secure) | S3 bucket with encryption, versioning, access logging | ✅ Stable |
| [iam-role](./modules/iam-role) | IAM roles with least-privilege policies and trust relationships | ✅ Stable |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  AWS Organization                    │
│                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │  Dev     │   │ Staging  │   │   Production     │ │
│  │ Account  │   │ Account  │   │   Account        │ │
│  └────┬─────┘   └────┬─────┘   └────────┬─────────┘ │
│       │              │                  │            │
│  ┌────▼──────────────▼──────────────────▼─────────┐ │
│  │         Shared Terraform Modules Library        │ │
│  │   vpc │ eks │ rds │ s3-secure │ iam-role        │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI configured with appropriate credentials
- S3 bucket and DynamoDB table for remote state (see [Remote State Setup](#remote-state-setup))

### Usage

```hcl
# Deploy a production-grade VPC
module "vpc" {
  source = "github.com/YOUR_USERNAME/terraform-aws-modules//modules/vpc"

  name               = "prod-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  enable_vpc_flow_logs = true

  tags = {
    Environment = "prod"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}

# Deploy EKS on top of that VPC
module "eks" {
  source = "github.com/YOUR_USERNAME/terraform-aws-modules//modules/eks"

  cluster_name    = "prod-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["m5.large"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
    }
  }

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

---

## Remote State Setup

All environments use remote state with S3 + DynamoDB locking to prevent concurrent modifications:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## Repository Structure

```
terraform-aws-modules/
├── modules/
│   ├── vpc/              # VPC module
│   ├── eks/              # EKS cluster module
│   ├── rds/              # RDS database module
│   ├── s3-secure/        # Secure S3 bucket module
│   └── iam-role/         # IAM role module
├── environments/
│   ├── dev/              # Dev environment composition
│   ├── staging/          # Staging environment composition
│   └── prod/             # Production environment composition
├── examples/
│   ├── complete-vpc/     # Full VPC example with all options
│   └── complete-eks/     # Full EKS cluster example
├── .github/
│   └── workflows/
│       └── terraform-ci.yml   # CI pipeline: fmt, validate, plan
└── README.md
```

---

## CI/CD Pipeline

Every pull request automatically runs:
1. `terraform fmt --check` — enforces consistent formatting
2. `terraform validate` — catches syntax and configuration errors
3. `terraform plan` — previews changes, output posted as PR comment
4. Security scan via `tfsec` — flags misconfigurations before merge

See [`.github/workflows/terraform-ci.yml`](.github/workflows/terraform-ci.yml)

---

## Security Defaults

Every module enforces security out of the box:

| Control | Implementation |
|---------|---------------|
| Encryption at rest | KMS encryption on all EBS, RDS, S3 resources |
| Encryption in transit | TLS enforced on RDS; S3 HTTPS-only bucket policy |
| Least-privilege IAM | Scoped IAM roles per module, no wildcard `*` actions |
| Network isolation | Private subnets by default; public access requires explicit opt-in |
| Audit logging | VPC flow logs, S3 access logs, CloudTrail compatible |
| State security | Remote state encrypted in S3 with DynamoDB locking |

---

## Contributing

1. Fork the repo and create a feature branch: `git checkout -b feat/your-module`
2. Follow module structure conventions (see any existing module)
3. Run `terraform fmt` and `terraform validate` before pushing
4. Open a PR — CI runs automatically

---

## Author

**Arun Kumar Konderu**  
Cloud Software Engineer | AWS Certified DevOps Engineer | CKA  
[LinkedIn](https://www.linkedin.com/in/arun-kumar-konderu-3b1373207) · [GitHub](https://github.com/YOUR_USERNAME)

---

## License

MIT License — see [LICENSE](LICENSE)
