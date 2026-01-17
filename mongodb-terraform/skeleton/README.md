# ${{ values.applicationName }} - MongoDB Atlas Infrastructure

MongoDB Atlas infrastructure managed by Terraform with Azure Private Endpoint and Azure AD OIDC authentication.

## Overview

This repository deploys MongoDB Atlas infrastructure using a workspace-per-environment pattern. Each workspace creates:

| Component | Description |
|-----------|-------------|
| **MongoDB Project** | Atlas project for resource isolation |
| **MongoDB Cluster** | Replica set or sharded cluster |
| **Azure Private Endpoint** | Secure connectivity from Azure VNet |
| **RBAC Mappings** | Azure AD groups mapped to Atlas roles |

## Customer Configuration TODOs

Before using this template, update the following hardcoded values:

| Item | Files | Current Value | Action |
|------|-------|---------------|--------|
| AWS Account ID | `.github/workflows/*.yml` | `123456789012` | Replace with your AWS account ID |
| GitHub Organization | `template.yaml` | `your-github-org` | Replace with your GitHub org |
| AWS OIDC Role Name | `.github/workflows/*.yml` | `your-oidc-role-name` | Replace with your OIDC role name |
| S3 State Bucket | `terraform/versions.tf`, `.github/workflows/*.yml` | `your-terraform-state-bucket` | Replace with your S3 bucket |
| AWS Secrets Manager Name | `terraform/variables.tf` | `your-secrets-manager-name` | Replace with your secret name |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure VNet                               │
│  ┌──────────────────┐     ┌──────────────────────────────────┐  │
│  │   Application    │────▶│   Private Endpoint (mongodb-pe)  │  │
│  └──────────────────┘     └──────────────────────────────────┘  │
└─────────────────────────────────|───────────────────────────────┘
                                  │ Private Link
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MongoDB Atlas                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                     Project                              │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │              Cluster (Replica Set)                 │  │   │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │  │   │
│  │  │  │ Primary │  │Secondary│  │Secondary│             │  │   │
│  │  │  └─────────┘  └─────────┘  └─────────┘             │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Workspaces

Each YAML file in `workspaces/` represents an environment:

```
workspaces/
├── dev.yaml      # Development environment
├── staging.yaml  # Staging environment
└── prod.yaml     # Production environment
```

### Adding a New Environment

Use Backstage to add a new environment:
1. Go to the Backstage Software Catalog
2. Select "Create" → "MongoDB Atlas Infrastructure"
3. Choose "Add environment to existing repository"
4. Fill in the environment configuration
5. Review and merge the generated Pull Request

Or manually:
1. Create a new YAML file in `workspaces/` (copy from existing)
2. Update the configuration values
3. Open a Pull Request
4. Review the Terraform plan in PR comments
5. Merge to apply

## CI/CD Pipeline

| Event | Workflow | Action |
|-------|----------|--------|
| Pull Request | `terraform-pr.yml` | Plan all workspaces, post summary as PR comment |
| Merge to Main | `terraform-merge.yml` | Apply changes to all workspaces sequentially |
| Manual Dispatch | `terraform-merge.yml` | Apply or Destroy specific/all workspaces |

## Prerequisites

### AWS Configuration

1. **OIDC Role**: GitHub OIDC role configured for this repository
   - Role ARN: `arn:aws:iam::{account}:role/github-oidc-backstage-terraform`

2. **Secrets Manager**: Secret containing credentials
   - Secret name: `mongodb-terraform-config`
   - Required keys:
     ```json
     {
       "mongodb_service_account_public_key": "...",
       "mongodb_service_account_private_key": "...",
       "org_id": "...",
       "azure_tenant_id": "...",
       "azure_client_id": "...",
       "azure_client_secret": "...",
       "azure_subscription_id": "..."
     }
     ```

az ad sp create-for-rbac --name backstage-sp --role "Owner" --scopes /subscriptions/$SUBSCRIPTION_ID

### Azure Configuration

- Resource Group with VNet
- Subnet for MongoDB Private Endpoints
- Azure AD Groups for RBAC
- Azure AD App Registration for OIDC

## Local Development

```bash
# Configure AWS credentials
aws sso login --profile your-profile
export AWS_PROFILE=your-profile

# Initialize Terraform
cd terraform
terraform init -backend-config="key=your-org/your-repo/workspaces/dev/terraform.tfstate"

# Select workspace
terraform workspace select dev || terraform workspace new dev

# Plan
terraform plan

# Apply (if authorized)
terraform apply
```

## Connection Examples

### Using mongosh with Azure AD OIDC

Connect without username/password using your Azure AD identity:

```bash
mongosh "mongodb+srv://cluster-name.mongodb.net" \
  --authenticationMechanism=MONGODB-OIDC \
  --oidcRedirectUri=http://localhost:27097/redirect
```

### Using Private Endpoint (from Azure)

From an application within the Azure VNet:

```bash
# Get the private endpoint connection string from Terraform outputs
mongosh "mongodb://private-endpoint-ip:27017/?directConnection=true"
```

### Using Standard Connection String

```bash
# Get connection string from Terraform outputs (sensitive)
terraform output -raw connection_strings
```

## RBAC Configuration

| Azure AD Group | Atlas Role | Access Level |
|----------------|------------|--------------|
| Admin Group | GROUP_OWNER | Full project access, manage users |
| Dev Group | GROUP_READ_ONLY | Read-only access to data |

## Terraform Modules Used

| Module | Version | Purpose |
|--------|---------|---------|
| [terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project) | initial-state | Create Atlas Projects |
| [terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster) | v0.2 | Create Atlas Clusters |

## Outputs

After applying, the following outputs are available:

| Output | Description |
|--------|-------------|
| `project_id` | MongoDB Atlas Project ID |
| `cluster_name` | Cluster name |
| `connection_strings` | MongoDB connection strings (sensitive) |
| `private_endpoint_ip` | Private endpoint IP address |
| `summary` | Full deployment summary |

```bash
# View all outputs
terraform output

# View specific output
terraform output -raw private_endpoint_ip
```

---

*Generated by [Backstage](https://backstage.io) Scaffolder*
