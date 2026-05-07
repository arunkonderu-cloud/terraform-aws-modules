# environments/dev/main.tf
# Dev environment - smaller footprint, lower cost, public endpoint enabled

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "your-tfstate-bucket-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { Environment = "dev", ManagedBy = "terraform" }
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = "dev-vpc"
  cidr               = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets     = ["10.1.101.0/24", "10.1.102.0/24"]
  enable_nat_gateway      = true
  enable_vpc_flow_logs    = true
  flow_log_retention_days = 7
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "dev-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  enable_public_endpoint = true # Dev convenience
  public_access_cidrs    = ["YOUR_OFFICE_IP/32"]

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 4
      desired_size   = 2
      capacity_type  = "SPOT" # Cost optimization in dev
    }
  }
}
