# =============================================================================
# AWS Secrets Manager Integration & Workspace Configuration (not reuseable)
# =============================================================================
# Secrets are fetched from AWS Secrets Manager rather than GitHub secrets.
# Workspace configuration is read from YAML files in the workspaces/ directory.

data "aws_secretsmanager_secret_version" "mongodb_config" {
  secret_id = var.aws_secrets_name
}

locals {
  # -----------------------------------------------------------------------------
  # Parse secrets from AWS Secrets Manager - Custom Bootstrap (not reuseable)
  # -----------------------------------------------------------------------------
  secrets = jsondecode(data.aws_secretsmanager_secret_version.mongodb_config.secret_string)

  # MongoDB Atlas Service Account credentials (OAuth2)
  client_id      = local.secrets.client_id
  client_secret  = local.secrets.client_secret
  mongodb_org_id = local.secrets.org_id

  # Azure credentials for private endpoint
  azure_tenant_id       = local.secrets.azure_tenant_id
  azure_client_id       = local.secrets.azure_client_id
  azure_client_secret   = local.secrets.azure_client_secret
  azure_subscription_id = local.secrets.azure_subscription_id

  # -----------------------------------------------------------------------------
  # Read workspace configuration from YAML file
  # -----------------------------------------------------------------------------
  workspace_file        = "${path.module}/../workspaces/${terraform.workspace}.yaml"
  workspace_file_exists = fileexists(local.workspace_file)
  workspace_config      = local.workspace_file_exists ? yamldecode(file(local.workspace_file)) : null
}

# Validate workspace file exists -- Custom handling for terraform workspaces
check "workspace_file_exists" {
  assert {
    condition     = local.workspace_file_exists
    error_message = "Workspace file '${local.workspace_file}' not found. Use 'terraform workspace select <env>' where <env> matches a file in workspaces/ (e.g., dev, staging, prod)."
  }
}

locals {
  # -----------------------------------------------------------------------------
  # Read DBA override configuration (optional file)
  # -----------------------------------------------------------------------------
  override_file        = "${path.module}/../workspaces/${terraform.workspace}-overrides.yaml"
  override_file_exists = fileexists(local.override_file)

  # Parse override file if it exists, otherwise use empty map
  override_config = local.override_file_exists ? yamldecode(file(local.override_file)) : {}

  # Safely extract cluster overrides
  override_cluster = try(local.override_config.cluster, {})

  # -----------------------------------------------------------------------------
  # Cluster Configuration (directly from workspace YAML)
  # -----------------------------------------------------------------------------
  # Region is specified directly in workspace config - no data lookups needed
  cluster_region = local.workspace_config.cluster.region

  # Regions for cluster (single region for REPLICASET)
  regions = [{
    name       = local.cluster_region
    node_count = 3
  }]

  # Effective min instance size for auto_scaling (DBA override > YAML > default)
  effective_min_instance_size = coalesce(
    try(local.override_cluster.instance_size, null),
    try(local.workspace_config.cluster.default_instance_size, null),
    "M30"
  )

  # -----------------------------------------------------------------------------
  # Naming convention
  # -----------------------------------------------------------------------------
  name_prefix = "${local.workspace_config.name}-${local.workspace_config.environment}"

  # -----------------------------------------------------------------------------
  # Common tags applied to all resources
  # -----------------------------------------------------------------------------
  common_tags = merge(
    {
      Application = local.workspace_config.name
      Environment = local.workspace_config.environment
      ManagedBy   = "terraform"
      CreatedBy   = "backstage-scaffolder"
    },
    var.additional_tags
  )
}
