# Hanover OCI Infrastructure Deployment

Central deployment configuration for all Hanover OCI infrastructure modules per TAD ICF2511.

## Quick Start

1. Update `terraform.tfvars` with your OCI credentials
2. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What Gets Deployed

### Resources Created (77 total)
- **43 IAM Groups** (including CIS-Auditors for compliance checking)
- **13 Compartments**:
  - 1 shared-services
  - 8 SaaS (Root + 7 sub-compartments)
  - 4 IaaS (Root + 3 sub-compartments, empty)
- **9 IAM Policies** (including CIS auditor policy)
- **3 Quota Policies** (zero quotas for SaaS, IaaS, and shared-services)
- **1 Tag Namespace** ("Operations")
- **3 Tags** (CostCenter, Environment, Application)
- **4 Tag Defaults** (ARCS-Prod and ARCS-Test)
- **3 Time delays** (60s each for IAM propagation)

## Deployment Order

The modules deploy automatically in this dependency order:
1. **Groups Module** - All IAM groups including ARCS roles
2. **Shared Services Compartment** - For security services
3. **SaaS Compartments** - EPM/ARCS hierarchy
4. **IaaS Compartments** - Empty structure for future use
5. **Policies Module** - All policies, quotas, and tags

## Current Configuration

### Active Services
- ARCS (Account Reconciliation) in prod/test environments
- Zero quotas preventing unauthorized resource creation
- CIS compliance auditing capability

### Reserved for Future
- IaaS infrastructure (Network, Applications, Database compartments)
- Other EPM modules (Planning, EDMCS, Freeform)
- Cloud Guard and logging services

## Quota Enforcement

All compartments have zero quotas to prevent unauthorized resources:
- **SaaS-Root**: No IaaS/PaaS resources allowed
- **IaaS-Root**: Locked until approved for use
- **shared-services**: Limited to security services only (1 VCN allowed)

## CIS Compliance

The deployment includes a CIS-Auditors group with permissions to run compliance checks:
```bash
# After deployment, run CIS compliance check
wget https://raw.githubusercontent.com/oci-landing-zones/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
oci session authenticate
python3 cis_reports.py -st --obp
```
or in Cloud Shell: 
```bash
wget https://raw.githubusercontent.com/oci-landing-zones/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
python3 cis_reports.py -dt --all-resources
```

## Future Activation

When ready to use IaaS or add more services:

1. **For IaaS activation**: Update quotas from "Zero" to actual limits
2. **For Network/Database admins**: Set `enable_iaas_policies = true`
3. **For environment separation**: Set `iaas_create_environments = true`

## Files Required

```
terraform.tfvars    # Your OCI credentials (not in git)
main.tf            # Module orchestration
variables.tf       # Variable definitions
outputs.tf         # Consolidated outputs
versions.tf        # Provider versions
provider.tf        # OCI provider config
```

## State Management

For production, consider remote state:
```hcl
terraform {
  backend "s3" {
    bucket = "hanover-terraform-state"
    key    = "oci/deployment/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Post-Deployment Steps

1. Add users to appropriate groups
2. Run CIS compliance check
3. Configure Cloud Guard when QRadar details available
4. Set up audit log collection in shared-services
5. Create ARCS application instances

## Troubleshooting

- **"Group does not exist"**: Check csv_groups.csv was updated
- **"Compartment does not exist"**: Ensure all modules deployed
- **"Permission denied"**: Verify your user has tenancy administrator rights