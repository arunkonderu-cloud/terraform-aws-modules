variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting EKS secrets and S3 objects"
  type        = string
  default     = null
}
