# =============================================================================
# Outputs
# =============================================================================
# Export key information about the deployed infrastructure.

# -----------------------------------------------------------------------------
# Project Outputs
# -----------------------------------------------------------------------------
output "project_id" {
  description = "MongoDB Atlas Project ID"
  value       = module.project.id
}

output "project_name" {
  description = "MongoDB Atlas Project Name"
  value       = local.name_prefix
}

# -----------------------------------------------------------------------------
# Cluster Outputs
# -----------------------------------------------------------------------------
output "cluster_id" {
  description = "MongoDB Atlas Cluster ID"
  value       = module.cluster.cluster_id
}

output "cluster_name" {
  description = "MongoDB Atlas Cluster Name"
  value       = local.name_prefix
}

output "connection_strings" {
  description = "MongoDB connection strings (use private endpoint string for Azure)"
  value       = module.cluster.connection_strings
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "privatelink" {
  description = "PrivateLink connection details per region"
  value       = module.atlas_azure.privatelink
}

output "private_endpoint_srv" {
  description = "MongoDB private endpoint SRV connection string"
  value       = try(module.cluster.connection_strings.private_endpoint[0].srv_connection_string, null)
}

# -----------------------------------------------------------------------------
# Summary Output
# -----------------------------------------------------------------------------
output "summary" {
  description = "Infrastructure deployment summary"
  value = {
    workspace           = terraform.workspace
    environment         = local.workspace_config.environment
    project_id          = module.project.id
    cluster_name        = local.name_prefix
    cluster_regions     = [for r in local.regions : r.name]
    privatelink_regions = [for ep in local.workspace_config.azure.privatelink_endpoints : ep.azure_location]
    lead_group_id      = local.workspace_config.azure.lead_group_id
    dev_group_id        = local.workspace_config.azure.dev_group_id
  }
}
