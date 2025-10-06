# OCI Core Policies Example

This example demonstrates how to deploy all IAM policies, quotas, and tags for the Hanover EPM implementation.

## Prerequisites

Before running this example, ensure the following resources exist:
1. **All IAM Groups** - Created by oci-core-deploy-groups module
2. **All Compartments** - Created by:
   - oci-core-deploy-shared-services (shared-services compartment)
   - oci-core-deploy-SaaS-apps-comp (SaaS-Root hierarchy)
   - oci-core-deploy-IaaS-Root (IaaS-Root hierarchy)

## What Gets Created

### IAM Policies (8)
- **admin-tenancy-policies** - Full tenancy management for Administrators group
- **iam-admin-policies** - IAM resource management
- **security-admin-policies** - Security services in shared-services
- **epm-service-admin-policies** - EPM service management
- **arcs-prod-admin-policies** - ARCS production environment
- **arcs-test-admin-policies** - ARCS test environment
- **finance-auditor-policies** - Read-only audit access
- **epm-user-policies** - EPM user access

### Quota Policies (2)
- **saas-compartment-restrictions** - Zero quotas preventing IaaS/PaaS in SaaS compartments
- **iaas-compartment-restrictions** - Zero quotas preventing resources in IaaS (until approved)

### Tags
- **Tag Namespace**: Operations
- **Tags**: CostCenter (cost tracking), Environment, Application

## Usage

```bash
# Copy and update variables
cp terraform.tfvars.example terraform.tfvars
# Edit with your credentials

# Deploy
terraform init
terraform plan
terraform apply
```

## Variables

Create a `terraform.tfvars` file with:
```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxx"
user_ocid        = "ocid1.user.oc1..xxxxxxxxxx"
fingerprint      = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
private_key_path = "~/.oci/key.pem"
region           = "us-ashburn-1"
```

## Outputs

After successful deployment:
- `policy_ids` - Map of all policy OCIDs
- `quota_ids` - Map of quota policy OCIDs
- `tag_namespace_id` - Operations namespace OCID
- `tag_ids` - Map of tag OCIDs

## Important Notes

1. **Groups Must Exist**: The following groups are referenced and must exist:
   - Administrators (or create it)
   - IAM_OCI_SECUREROLE_IAMAdmins
   - IAM_OCI_SECUREROLE_SECAdmins
   - ARCS-Prod-Admins (or create it)
   - ARCS-Test-Admins (or create it)
   - Finance-Auditors (or create it)

2. **Compartments Must Exist**: Policies reference these compartments:
   - shared-services
   - SaaS-Root (and children)
   - IaaS-Root (and children)

3. **Zero Quotas**: Both SaaS and IaaS have zero quotas to prevent unauthorized resource creation

## Troubleshooting

### Error: "group does not exist"
The referenced group hasn't been created. Check the groups module output.

### Error: "compartment does not exist"
Deploy all compartment modules before this policies module.

### Error: "quota statement invalid"
Verify compartment names match exactly with created compartments.
