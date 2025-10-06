# Complete SaaS Compartments Example

This example demonstrates how to deploy the complete SaaS compartment hierarchy for Oracle EPM applications using the module.

## Overview

This example creates an 8-compartment hierarchy organized into 3 levels:
- 1 root compartment (SaaS-Root)
- 2 child compartments (ARCS, Other-EPM)
- 5 grandchild compartments (ARCS-Prod, ARCS-Test, Planning, EDMCS, Freeform)

> **Note**: This module only creates compartment structures. IAM policies, quotas, and tag namespaces are managed separately in the `oci-core-policies` module to maintain separation of concerns.

## Prerequisites

Before running this example, ensure you have:

1. **OCI Account**: Active Oracle Cloud Infrastructure account with a tenancy
2. **API Keys**: Generated API key pair for authentication
3. **Permissions**: User must have permissions to create compartments in the tenancy
4. **Terraform**: Terraform CLI installed (version >= 1.3)

## Setup

### 1. Configure Variables

Create a `terraform.tfvars` file with your OCI credentials:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaaxxxxxxxx"
fingerprint      = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
```

**Security Note**: Never commit `terraform.tfvars` to version control. Add it to `.gitignore`.

### 2. Initialize Terraform

```bash
terraform init
```

This will download the required providers:
- `oracle/oci` (>= 6.0.0)
- `hashicorp/time` (>= 0.9.0)

### 3. Review the Plan

```bash
terraform plan
```

Expected resources to be created:
- 8 OCI compartments
- 1 time_sleep resource (for IAM propagation)

### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the changes.

**Note**: The apply process includes a 60-second wait for IAM propagation. This ensures compartments are available across all OCI regions before proceeding.

## Resources Created

This example creates the following OCI resources:

### Compartment Hierarchy

```
SaaS-Root
├── ARCS
│   ├── ARCS-Prod (Tagged: Production, SOX Compliance)
│   └── ARCS-Test (Tagged: Test)
└── Other-EPM
    ├── Planning (Tagged: Parked - Future Migration)
    ├── EDMCS (Tagged: Parked - Future Migration)
    └── Freeform (Tagged: Parked - Future Migration)
```

### Tags Applied

Each compartment includes freeform tags for organization and tracking:

- **ARCS-Prod**:
  - `Environment = "Production"`
  - `Application = "ARCS"`
  - `Compliance = "SOX"`
  - `ManagedBy = "Terraform"`

- **ARCS-Test**:
  - `Environment = "Test"`
  - `Application = "ARCS"`
  - `ManagedBy = "Terraform"`

- **Parked Applications** (Planning, EDMCS, Freeform):
  - `Environment = "Parked"`
  - `Application = "<app-name>"`
  - `ManagedBy = "Terraform"`

## Outputs

After successful apply, you'll see the following outputs:

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

Use these OCIDs to reference the compartments in other Terraform configurations or OCI operations.

## Customization

You can customize the compartment hierarchy by modifying the `compartment_hierarchy` block in `main.tf`. For example:

```hcl
compartment_hierarchy = {
  "SaaS-Root" = {
    description = "Custom description"
    children = {
      "CustomApp" = {
        description = "Custom application compartment"
        children = {
          "CustomApp-Prod" = {
            description = "Production environment"
            tags = { Environment = "Production" }
          }
        }
      }
    }
  }
}
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

**Important**: Compartments must be empty before they can be deleted. Remove all resources within compartments first, then run destroy.

## Troubleshooting

### Issue: "403 NotAuthorized"
**Solution**: Verify your user has permissions to create compartments in the tenancy. Contact your OCI administrator.

### Issue: "Invalid fingerprint format"
**Solution**: Ensure your fingerprint is in the correct format: `aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99`

### Issue: "Private key not found"
**Solution**: Verify the `private_key_path` points to your actual private key file.

### Issue: Compartments not appearing immediately
**Solution**: This is normal. The module includes a 60-second wait for IAM propagation. If issues persist, check the OCI Console directly.

## Files

- `main.tf` - Main configuration using the module
- `README.md` - This file

## Next Steps

After creating the compartments, you typically would:

1. Deploy the groups module to create IAM groups
2. Deploy the policies module to:
   - Create IAM policies controlling access to these compartments
   - Set up quotas to prevent unauthorized IaaS/PaaS resource creation
   - Configure tag namespaces and defaults for governance
3. Deploy EPM SaaS applications into the appropriate compartments
4. Configure Cloud Guard and logging for security compliance

## Reference

For more information, see the [main module documentation](../../README.md).
