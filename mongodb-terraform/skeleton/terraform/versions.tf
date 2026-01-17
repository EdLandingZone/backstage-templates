# =============================================================================
# Terraform and Provider Version Requirements
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  # S3 backend for remote state storage
  # The 'key' is provided via -backend-config in the CI/CD workflow
  backend "s3" {
    bucket = "new-aws-bucket"
    region = "us-east-1"
    # key is set dynamically: {repo}/workspaces/{workspace}/terraform.tfstate
  }

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.53"
    }
  }
}
