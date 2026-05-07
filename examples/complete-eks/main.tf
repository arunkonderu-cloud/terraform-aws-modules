# examples/complete-eks/main.tf
# Full EKS cluster on top of the VPC module

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "us-east-1" }

module "vpc" {
  source             = "../../modules/vpc"
  name               = "eks-example-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  tags               = { Environment = "example" }
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "example-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = { Environment = "example" }
}

output "cluster_endpoint"   { value = module.eks.cluster_endpoint }
output "oidc_provider_arn"  { value = module.eks.oidc_provider_arn }
