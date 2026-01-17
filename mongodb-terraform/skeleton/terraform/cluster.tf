# =============================================================================
# MongoDB Atlas Cluster Configuration
# =============================================================================
# Creates the MongoDB Atlas Cluster using the official Terraform module.

# -----------------------------------------------------------------------------
# MongoDB Atlas Cluster should be expanded for different cluster types and backup policies
# -----------------------------------------------------------------------------
module "cluster" {
  source = "git::https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster.git"

  project_id    = module.project.id
  name          = local.name_prefix
  cluster_type  = "REPLICASET"
  provider_name = "AZURE"

  regions = local.regions

  # Auto-scaling enabled by default for production readiness
  auto_scaling = {
    compute_enabled            = true
    compute_min_instance_size  = local.effective_min_instance_size
    compute_scale_down_enabled = true
    disk_gb_enabled            = true
  }

  # Disable termination protection for easier cleanup during development
  termination_protection_enabled = false
}

