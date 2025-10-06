# OCI Groups Module

## Purpose
Creates and manages OCI IAM groups for the Hanover EPM implementation per TAD ICF2511.

## Architecture
This module creates IAM groups at the tenancy level that will be referenced by policies to control access to compartments and resources.

## Features
- CSV-based group import (pure Terraform, no shell dependencies)
- Programmatic group creation via variables
- Automatic tagging and descriptions
- Support for both freeform and defined tags
- Intelligent handling of empty CSV fields

## Module Structure
```
oci-core-deploy-groups/
├── README.md              # This file
├── main.tf               # Group resources
├── variables.tf          # Input variables
├── outputs.tf           # Output definitions
├── locals.tf            # CSV parsing logic
├── provider.tf          # OCI provider config
├── versions.tf          # Version constraints
├── csv_groups.csv       # Group definitions
└── examples/
    └── complete/        # Working example
        ├── main.tf
        ├── README.md
        └── terraform.tfvars.example
```

## Usage

### Basic Usage (CSV File)
```hcl
module "groups" {
  source = "./oci-core-deploy-groups"
  
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  
  use_csv = true  # Default - uses csv_groups.csv
}
```

### Programmatic Usage
```hcl
module "groups" {
  source = "./oci-core-deploy-groups"
  
  # ... auth variables ...
  
  use_csv = false
  
  iam_groups = {
    "Finance-Admins" = {
      description = "Finance administrators"
      freeform_tags = {
        Owner       = "Finance"
        Environment = "PROD"
      }
    }
  }
}
```

## Groups Created from CSV

The module creates **36 groups** organized by function:

### Administrative Groups (2)
- `IAM_OCI_SECUREROLE_IAMAdmins` - IAM administrators
- `IAM_OCI_SECUREROLE_SECAdmins` - Security administrators

### EPM Service Groups (4)
- `IAM_OCI_SECUREROLE_EPM_ServiceAdministrators` - EPM service administrators
- `IAM_OCI_SECUREROLE_EPM_PowerUsers` - Power users
- `IAM_OCI_SECUREROLE_EPM_Users` - Standard EPM users
- `IAM_OCI_SECUREROLE_Viewer` - Read-only viewers

### Core Application Groups (3)
- `EPM_Admins` - EPM environment administrators
- `ARCS_Users` - ARCS module users
- `Finance_ReadOnly` - Read-only financial data access

### ARCS Role Groups (27)
Granular ARCS application roles including:
- Access Control (Manage/View)
- Data Integration (Administrator/Create/Run)
- Reconciliation roles (Preparer/Reviewer/Commentator)
- Functional management (Periods, Teams, Users, Reports, etc.)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| tenancy_ocid | OCI Tenancy OCID | `string` | n/a | yes |
| user_ocid | OCI User OCID | `string` | n/a | yes |
| fingerprint | API key fingerprint | `string` | n/a | yes |
| private_key_path | Path to private key file | `string` | n/a | yes |
| region | OCI region | `string` | n/a | yes |
| private_key_password | Private key password if encrypted | `string` | `""` | no |
| use_csv | Use CSV file for group definitions | `bool` | `true` | no |
| iam_groups | Map of IAM group definitions | `map(object)` | `{}` | no |
| default_tags | Default tags applied to all groups | `map(string)` | See below | no |

### Default Tags
```hcl
{
  ManagedBy = "Terraform"
  Module    = "oci-core-deploy-groups"
}
```

## Outputs

| Name | Description |
|------|-------------|
| group_ids | Map of group names to OCIDs |
| group_names | List of all created group names |
| groups_by_owner | Groups organized by Owner tag |

## CSV Format

The `csv_groups.csv` file should have the following format:
```csv
name,description,Environment,Owner
GroupName,Group Description,PROD,Team Name
```

Empty fields are handled gracefully with defaults:
- Missing description: Uses "{name} group"
- Missing Environment: Defaults to "PROD"
- Missing Owner: Defaults to "Finance"

## Requirements

- Terraform >= 1.3
- OCI Provider >= 6.0.0

## Deployment Order

This module should be deployed **first** in your infrastructure as other modules depend on these groups:
1. **Groups Module** (this module) - Create IAM groups
2. Compartment Modules - Create compartment hierarchy
3. Policies Module - Link groups to compartments via policies

## Example

See [examples/complete](./examples/complete) for a full working example.

## Notes

- Groups are created at the tenancy level (global)
- Groups must be empty before deletion
- Group names must be unique within the tenancy
- The CSV parsing is done in pure Terraform (no external dependencies)

## License

Copyright (c) 2025. All rights reserved.