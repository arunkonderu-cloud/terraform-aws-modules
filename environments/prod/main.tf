# -----------------------------------------------------------------------------
# environments/prod/main.tf
# Production environment - composes VPC + EKS + S3 modules
# Demonstrates multi-environment, multi-account Terraform pattern
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state: S3 backend with DynamoDB locking
  backend "s3" {
    bucket         = "your-tfstate-bucket-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "terraform"
      Repository  = "terraform-aws-modules"
    }
  }
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  name               = "prod-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = true
  enable_vpc_flow_logs    = true
  flow_log_retention_days = 90 # 90 days for prod compliance

  tags = { Team = "platform" }
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "prod-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  enable_public_endpoint = false # Private-only in prod
  kms_key_arn            = var.kms_key_arn

  node_groups = {
    general = {
      instance_types = ["m5.xlarge"]
      min_size       = 3
      max_size       = 20
      desired_size   = 5
      capacity_type  = "ON_DEMAND"
    }
    spot = {
      instance_types = ["m5.large", "m5.xlarge", "m4.xlarge"]
      min_size       = 0
      max_size       = 10
      desired_size   = 2
      capacity_type  = "SPOT"
      labels         = { workload = "batch" }
    }
  }

  tags = { Team = "platform" }
}

# -----------------------------------------------------------------------------
# S3 — Terraform State Bucket (if bootstrapping)
# -----------------------------------------------------------------------------
module "tfstate_bucket" {
  source = "../../modules/s3-secure"

  bucket_name       = "your-tfstate-bucket-prod"
  enable_versioning = true
  kms_key_arn       = var.kms_key_arn

  lifecycle_rules = [{
    id      = "expire-old-versions"
    enabled = true
    transitions = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }]
    expiration_days = 365
  }]

  tags = { Purpose = "terraform-state" }
}
