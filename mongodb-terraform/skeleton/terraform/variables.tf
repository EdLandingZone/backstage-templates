# =============================================================================
# Variables
# =============================================================================
# Most configuration comes from workspace YAML files and AWS Secrets Manager.
# These variables are for overrides and global settings.

variable "aws_secrets_name" {
  description = "Name of the AWS Secrets Manager secret containing MongoDB and Azure credentials"
  type        = string
}

variable "aws_region" {
  description = "AWS region for Secrets Manager access"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
