# variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning for data protection"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption. If null, uses AES-256."
  type        = string
  default     = null
}

variable "access_log_bucket" {
  description = "S3 bucket name to send access logs to. If null, logging is disabled."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects. Use with caution."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for cost optimization"
  type = list(object({
    id      = string
    enabled = bool
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration_days = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
