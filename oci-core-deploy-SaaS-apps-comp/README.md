# SaaS Apps Compartment Module

Terraform module for creating OCI compartment hierarchy for Oracle EPM SaaS applications per TAD ICF2511.

## Purpose

This module creates a structured compartment hierarchy in Oracle Cloud Infrastructure (OCI) specifically designed for Oracle EPM (Enterprise Performance Management) SaaS applications. It establishes an organized separation between production, test, and parked (future) environments.

## Architecture

The module creates the following 3-level compartment hierarchy:

```
Tenancy Root
└── SaaS-Root (Root compartment for all SaaS applications - EPM Suite)
    ├── ARCS (Account Reconciliation Cloud Service)
    │   ├── ARCS-Prod (ARCS Production Environment)
    │   └── ARCS-Test (ARCS Test/UAT Environment)
    └── Other-EPM (Other EPM Applications - Parked)
        ├── Planning (Oracle Planning Cloud - Future Migration)
        ├── EDMCS (Enterprise Data Management Cloud - Future Migration)
        └── Freeform (Freeform Planning - Future Migration)
```

**Total compartments created**: 8
- 1 root compartment (SaaS-Root)
- 2 child compartments (ARCS, Other-EPM)
- 5 grandchild compartments (ARCS-Prod, ARCS-Test, Planning, EDMCS, Freeform)

## Scope

This module focuses solely on **compartment creation**. It does NOT include:
- IAM policies (managed separately in oci-core-policies module)
- Quotas (managed separately in oci-core-policies module)
- Tag namespaces and defaults (managed separately in oci-core-policies module)

This separation follows infrastructure-as-code best practices by maintaining single responsibility for each module.

## Features

- **Hierarchical Structure**: 3-level compartment nesting for logical organization
- **Automated Tagging**: Freeform tags automatically applied to all compartments
- **IAM Propagation Wait**: 60-second delay ensures compartments are fully propagated before downstream operations
- **Enable Delete**: All compartments created with `enable_delete = true` for easier cleanup during development/testing

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| oci | >= 6.0.0 |
| time | >= 0.9.0 |

## Provider Configuration

You need to configure the OCI provider with your credentials:

```hcl
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
```

## Usage

### Basic Example

```hcl
module "saas_compartments" {
  source = "./oci-core-deploy-SaaS-apps-comp"

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
```

### Complete Example

See the [examples/complete](./examples/complete) directory for a full working example.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenancy_ocid | OCI Tenancy OCID | `string` | n/a | yes |
| user_ocid | OCI User OCID | `string` | n/a | yes |
| fingerprint | API key fingerprint | `string` | n/a | yes |
| private_key_path | Path to private key file | `string` | n/a | yes |
| region | OCI region | `string` | n/a | yes |
| private_key_password | Private key password (if encrypted) | `string` | `""` | no |

### Supported OCI Regions

The module validates against the following regions:
- US: `us-ashburn-1`, `us-phoenix-1`, `us-sanjose-1`
- Canada: `ca-toronto-1`, `ca-montreal-1`
- Europe: `eu-frankfurt-1`, `eu-amsterdam-1`, `uk-london-1`, `eu-zurich-1`
- Asia Pacific: `ap-mumbai-1`, `ap-seoul-1`, `ap-sydney-1`, `ap-osaka-1`, `ap-tokyo-1`
- South America: `sa-saopaulo-1`, `sa-vinhedo-1`
- Middle East: `me-jeddah-1`, `me-dubai-1`

## Outputs

| Name | Description |
|------|-------------|
| compartment_ids | Map of compartment names to OCIDs |
| compartment_tree | Structured compartment IDs for easy reference |

### Example Output

```hcl
compartment_ids = {
  "SaaS-Root"  = "ocid1.compartment.oc1..aaaaaaa..."
  "ARCS"       = "ocid1.compartment.oc1..aaaaaaa..."
  "ARCS-Prod"  = "ocid1.compartment.oc1..aaaaaaa..."
  "ARCS-Test"  = "ocid1.compartment.oc1..aaaaaaa..."
  "Other-EPM"  = "ocid1.compartment.oc1..aaaaaaa..."
  "Planning"   = "ocid1.compartment.oc1..aaaaaaa..."
  "EDMCS"      = "ocid1.compartment.oc1..aaaaaaa..."
  "Freeform"   = "ocid1.compartment.oc1..aaaaaaa..."
}

compartment_tree = {
  "saas_root_id"        = "ocid1.compartment.oc1..aaaaaaa..."
  "arcs_compartment_id" = "ocid1.compartment.oc1..aaaaaaa..."
  "arcs_prod_id"        = "ocid1.compartment.oc1..aaaaaaa..."
  "arcs_test_id"        = "ocid1.compartment.oc1..aaaaaaa..."
  "other_epm_id"        = "ocid1.compartment.oc1..aaaaaaa..."
}
```

## Module Structure

```
.
├── main.tf                           # Root module configuration
├── variables.tf                      # Input variable definitions
├── outputs.tf                        # Output definitions
├── provider.tf                       # OCI provider configuration
├── versions.tf                       # Terraform and provider version constraints
├── locals.tf                         # Local values for common tags and mappings
├── modules/
│   └── saas-apps-hierarchy/         # Compartment hierarchy submodule
│       ├── main.tf                   # Compartment resources
│       ├── variables.tf              # Module variables
│       ├── outputs.tf                # Module outputs
│       ├── locals.tf                 # Local computations
│       └── versions.tf               # Version requirements
└── examples/
    └── complete/                     # Complete usage example
        ├── main.tf
        └── README.md
```

## How It Works

1. **Root Compartments**: Creates top-level compartments (SaaS-Root)
2. **Child Compartments**: Creates second-level compartments (ARCS, Other-EPM) under SaaS-Root
3. **Grandchild Compartments**: Creates third-level compartments (ARCS-Prod, ARCS-Test, etc.) under their parent compartments
4. **IAM Propagation**: Waits 60 seconds for IAM changes to propagate across OCI regions
5. **Outputs**: Returns compartment OCIDs for use in other modules or resources

## Tags Applied

Each compartment receives freeform tags only:
- **All compartments**: `ManagedBy = "Terraform"`
- **Root compartments**: `Purpose = "SaaS-Applications"`
- **Child/grandchild compartments**: Environment and Application tags as specified in the compartment hierarchy configuration

Example tags applied to grandchild compartments:
- **ARCS-Prod**: `Environment = "Production"`, `Application = "ARCS"`, `Compliance = "SOX"`, `ManagedBy = "Terraform"`
- **ARCS-Test**: `Environment = "Test"`, `Application = "ARCS"`, `ManagedBy = "Terraform"`
- **Planning**: `Environment = "Parked"`, `Application = "Planning"`, `ManagedBy = "Terraform"`
- **EDMCS**: `Environment = "Parked"`, `Application = "EDMCS"`, `ManagedBy = "Terraform"`
- **Freeform**: `Environment = "Parked"`, `Application = "Freeform"`, `ManagedBy = "Terraform"`

## Deployment Order

This module should be deployed as part of a larger infrastructure rollout:

1. **Groups Module** - Create IAM groups first
2. **Compartment Modules** - Create this and other compartment structures
3. **Policies Module** - Create all policies, quotas, and governance controls

See the parent repository for complete deployment instructions.

## Important Notes

- **IAM Permissions**: User/service principal must have permission to create compartments in the tenancy
- **Cleanup**: Compartments created with `enable_delete = true` can be deleted via Terraform, but must be empty first
- **Propagation Time**: The 60-second wait ensures compartments are available across all OCI regions before use
- **OCID Validation**: Input validation ensures tenancy and user OCIDs follow correct format

## License

Copyright (c) 2025. All rights reserved.
