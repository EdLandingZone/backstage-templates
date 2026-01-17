# =============================================================================
# MongoDB Atlas Project & RBAC Configuration
# =============================================================================
# Creates the MongoDB Atlas Project and configures Azure AD group role mappings.

# -----------------------------------------------------------------------------
# MongoDB Atlas Project Module
# -----------------------------------------------------------------------------
module "project" {
  source = "./modules/project"

  name   = local.name_prefix
  org_id = local.mongodb_org_id

  # IP Access List - use CIDR as key, comment uses module default
  access_cidrs = {
    for cidr in local.workspace_config.network.access_cidrs :
    cidr => { cidr_block = cidr }
  }
}

# -----------------------------------------------------------------------------
# Federated Settings - Organization Configuration
# -----------------------------------------------------------------------------
data "mongodbatlas_federated_settings" "org" {
  org_id = local.mongodb_org_id
}

# -----------------------------------------------------------------------------
# Azure AD Group Role Mapping - Lead Group (Project Owner)
# This implementation is not ideal as it wont allow for 2 different project assignments
# -----------------------------------------------------------------------------
resource "mongodbatlas_federated_settings_org_role_mapping" "lead" {
  federation_settings_id = data.mongodbatlas_federated_settings.org.id
  org_id                 = local.mongodb_org_id
  external_group_name    = local.workspace_config.azure.lead_group_id

  # Must include at least one org role
  role_assignments {
    org_id = local.mongodb_org_id
    roles  = ["ORG_MEMBER"]
  }

  role_assignments {
    group_id = module.project.id
    roles    = ["GROUP_OWNER"]
  }
}

# -----------------------------------------------------------------------------
# Azure AD Group Role Mapping - Dev Group (Project Read Only)
# This implementation is not ideal as it wont allow for 2 different project assignments
# -----------------------------------------------------------------------------
resource "mongodbatlas_federated_settings_org_role_mapping" "dev" {
  federation_settings_id = data.mongodbatlas_federated_settings.org.id
  org_id                 = local.mongodb_org_id
  external_group_name    = local.workspace_config.azure.dev_group_id

  # Must include at least one org role
  role_assignments {
    org_id = local.mongodb_org_id
    roles  = ["ORG_MEMBER"]
  }

  role_assignments {
    group_id = module.project.id
    roles    = ["GROUP_READ_ONLY"]
  }
}
