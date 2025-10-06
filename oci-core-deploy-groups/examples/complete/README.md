# Complete Groups Example

This example demonstrates how to deploy all IAM groups required for the Hanover EPM implementation.

## Overview

Creates 36 IAM groups organized by functional area:
- **Core Groups** (3): General EPM administration and read-only access
- **IAM/Security Groups** (2): IAM and Security administrators  
- **EPM Service Groups** (4): Service-level administration and user access
- **ARCS Role Groups** (27): Granular ARCS application roles

## Prerequisites

1. **OCI Tenancy**: Active Oracle Cloud Infrastructure tenancy
2. **API Keys**: Generated API key pair for authentication
3. **Permissions**: User must have `manage groups` permission in the tenancy
4. **Terraform**: Version >= 1.3 installed

## Usage

### Step 1: Configure Variables

Copy and update the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your OCI credentials:
```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxxxx"  
fingerprint      = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

You should see 36 groups to be created.

### Step 4: Apply

```bash
terraform apply
```

Type `yes` when prompted.

## Groups Created

### Administrative Groups
- `IAM_OCI_SECUREROLE_IAMAdmins` - IAM administrators
- `IAM_OCI_SECUREROLE_SECAdmins` - Security administrators

### EPM Service Groups  
- `IAM_OCI_SECUREROLE_EPM_ServiceAdministrators` - EPM service admins
- `IAM_OCI_SECUREROLE_EPM_PowerUsers` - Power users
- `IAM_OCI_SECUREROLE_EPM_Users` - Standard users
- `IAM_OCI_SECUREROLE_Viewer` - Read-only viewers

### ARCS-Specific Groups
27 granular role groups for ARCS including:
- Access Control (Manage/View)
- Data Integration (Administrator/Create/Run)
- Reconciliation (Preparer/Reviewer/Commentator)
- Various management roles (Periods, Profiles, Teams, Users, etc.)

## Outputs

The module provides three outputs:

1. **group_ids**: Map of group names to OCIDs
2. **group_names**: List of all created group names
3. **groups_by_owner**: Groups organized by their Owner tag

Example output:
```
groups_by_owner = {
  "Finance"       = [31 groups]
  "IAM Team"      = ["EPM_Admins", "IAM_OCI_SECUREROLE_IAMAdmins"]
  "Security Team" = ["IAM_OCI_SECUREROLE_SECAdmins"]
  "ARCS Lead"     = ["ARCS_Users"]
}
```

## Customization

### Using Different Groups

To use your own group definitions instead of the CSV:

```hcl
module "groups" {
  source = "../../"
  
  # ... auth variables ...
  
  use_csv = false
  
  iam_groups = {
    "Custom-Group" = {
      description = "My custom group"
      freeform_tags = {
        Owner       = "Custom Team"
        Environment = "DEV"
      }
    }
  }
}
```

### Modifying the CSV

Edit `../../csv_groups.csv` to add/remove/modify groups. Format:
```csv
name,description,Environment,Owner
GroupName,Group Description,PROD,Team Name
```

## Cleanup

To destroy all groups:

```bash
terraform destroy
```

**Note**: Groups must be empty (no users) before they can be deleted.

## Troubleshooting

### Error: "401 NotAuthenticated"
Verify your API credentials and key path.

### Error: "403 NotAuthorized"  
Ensure your user has `manage groups` permission in the tenancy.

### Error: Group already exists
Check if groups were created manually or by another process.

## Next Steps

After creating groups:
1. Deploy compartment structures (SaaS-Root, IaaS-Root, Shared-Services)
2. Create IAM policies linking groups to compartments
3. Add users to appropriate groups
4. Configure federation/IDCS if required

## Files

- `main.tf` - Module configuration
- `terraform.tfvars.example` - Example variables
- `README.md` - This file
