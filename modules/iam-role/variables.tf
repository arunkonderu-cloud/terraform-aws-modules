# variables.tf
variable "role_name" { type = string }
variable "description" { type = string; default = "" }
variable "path" { type = string; default = "/" }
variable "max_session_duration" { type = number; default = 3600 }
variable "trust_policy_statements" { type = any }
variable "managed_policy_arns" { type = list(string); default = [] }
variable "inline_policy" { type = any; default = null }
variable "create_instance_profile" { type = bool; default = false }
variable "tags" { type = map(string); default = {} }

# outputs.tf
