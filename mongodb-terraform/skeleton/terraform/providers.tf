# =============================================================================
# Provider Configuration
# =============================================================================
# MongoDB Atlas, Azure, and AWS providers are configured here.
# Credentials are sourced from AWS Secrets Manager via locals.tf.

# -----------------------------------------------------------------------------
# MongoDB Atlas Provider
# -----------------------------------------------------------------------------
provider "mongodbatlas" {
  client_id     = local.client_id
  client_secret = local.client_secret
  base_url      = local.secrets.mongodb_atlas_base_url
}

# -----------------------------------------------------------------------------
# Azure Provider - for Private Endpoint
# -----------------------------------------------------------------------------
provider "azurerm" {
  features {}

  subscription_id = local.azure_subscription_id
  client_id       = local.azure_client_id
  client_secret   = local.azure_client_secret
  tenant_id       = local.azure_tenant_id
}

# -----------------------------------------------------------------------------
# Azure AD Provider - for role mappings (required by atlas_azure module)
# -----------------------------------------------------------------------------
provider "azuread" {
  tenant_id     = local.azure_tenant_id
  client_id     = local.azure_client_id
  client_secret = local.azure_client_secret
}

# -----------------------------------------------------------------------------
# AWS Provider - for Secrets Manager access
# Credentials via OIDC in GitHub Actions
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}
