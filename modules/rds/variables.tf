# variables.tf
variable "identifier"                  { type = string }
variable "engine"                      { type = string; default = "postgres" }
variable "engine_version"              { type = string; default = "15.4" }
variable "instance_class"              { type = string; default = "db.t3.medium" }
variable "allocated_storage"           { type = number; default = 20 }
variable "db_name"                     { type = string }
variable "username"                    { type = string }
variable "password"                    { type = string; sensitive = true }
variable "port"                        { type = number; default = 5432 }
variable "vpc_id"                      { type = string }
variable "subnet_ids"                  { type = list(string) }
variable "allowed_security_group_ids"  { type = list(string); default = [] }
variable "kms_key_arn"                 { type = string; default = null }
variable "multi_az"                    { type = bool; default = true }
variable "backup_retention_days"       { type = number; default = 7 }
variable "deletion_protection"         { type = bool; default = true }
variable "skip_final_snapshot"         { type = bool; default = false }
variable "tags"                        { type = map(string); default = {} }
