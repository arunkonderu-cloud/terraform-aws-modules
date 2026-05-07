# -----------------------------------------------------------------------------
# EKS Module - variables.tf
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node groups (use private subnets)"
  type        = list(string)
}

variable "enable_public_endpoint" {
  description = "Enable public API server endpoint. Set false for private-only clusters."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access the public API endpoint (if enabled)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting Kubernetes secrets at rest. Recommended for production."
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
  }))
  default = {
    general = {
      instance_types = ["m5.large"]
      min_size       = 2
      max_size       = 5
      desired_size   = 2
    }
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
