# =============================================================================
# Azure Integration 
# =============================================================================
# Configures Azure Private Endpoints using the terraform-mongodbatlas-atlas-azure module.

module "atlas_azure" {
  source = "git::https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure.git"

  project_id = module.project.id

  # Skip cloud provider access setup (not needed for network only)
  skip_cloud_provider_access = true

  # Configure privatelink endpoints directly from workspace config
  privatelink_endpoints = {
    for ep in local.workspace_config.azure.privatelink_endpoints :
    ep.azure_location => { subnet_id = ep.subnet_id }
  }
}
