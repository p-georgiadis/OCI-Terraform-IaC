# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform-based Infrastructure as Code (IaC) repository for deploying CIS-compliant Oracle Cloud Infrastructure (OCI) for Hanover's EPM implementation. The codebase uses a modular architecture to deploy IAM groups, compartments, policies, and security services (Cloud Guard, event monitoring, notifications).

**Key Architecture Principle**: All infrastructure is deployed through the central `deployment/` directory, which orchestrates 6 modules in a specific dependency order.

## Build, Test, and Deploy Commands

### Terraform Operations

All Terraform commands should be run from the `deployment/` directory:

```bash
cd deployment

# Initialize Terraform (required first time or after module changes)
terraform init

# Validate configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Plan changes (review before applying)
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure (use with caution)
terraform destroy

# Show current state
terraform show

# List all resources in state
terraform state list

# View outputs
terraform output
```

### Testing Individual Modules

To test or plan a single module without deploying everything:

```bash
# Example: Test the security module
cd oci-core-deploy-security
terraform init
terraform plan -var="tenancy_ocid=ocid1..." -var="region=us-ashburn-1" ...

# Note: Most modules require compartment IDs from other modules,
# so testing in isolation may require manual variable values
```

### Validation

```bash
# Validate all Terraform files recursively
terraform fmt -check -recursive

# Check for Terraform syntax errors
find . -name "*.tf" -type f -exec dirname {} \; | sort -u | while read dir; do
  echo "Validating $dir"
  (cd "$dir" && terraform init -backend=false && terraform validate)
done
```

### Running CIS Compliance Check

After deployment, verify CIS compliance:

```bash
# Download CIS compliance checker
wget https://raw.githubusercontent.com/oci-landing-zones/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py

# Run compliance check (requires OCI CLI configured)
python3 cis_reports.py -dt --all-resources

# This generates HTML reports in CIS REPORT/ directory
```

## Architecture and Code Structure

### Deployment Flow

The `deployment/main.tf` orchestrates module deployment in this order:

1. **Groups** (`oci-core-deploy-groups`) - Creates 43 IAM groups from CSV
2. **Shared Services** (`oci-core-deploy-shared-services`) - Creates shared-services compartment
3. **SaaS Compartments** (`oci-core-deploy-SaaS-apps-comp`) - Creates ARCS and EPM compartments
4. **IaaS Compartments** (`oci-core-deploy-IaaS-Root`) - Creates locked-down IaaS structure
5. **Security** (`oci-core-deploy-security`) - Deploys Cloud Guard, notifications, event rules
6. **Policies** (`oci-core-policies`) - Deploys IAM policies, quotas, and tags (must be last)

**Critical**: The security module depends on shared-services compartment. The policies module depends on all other modules.

### Module Locations and Responsibilities

- **`deployment/`**: Central orchestration point. Contains `main.tf`, `variables.tf`, `outputs.tf`, and `terraform.tfvars.example`
- **`oci-core-deploy-groups/`**: Reads `csv_groups.csv` to create IAM groups. CSV format: `name,description,Environment,Owner`
- **`oci-core-deploy-shared-services/`**: Creates single compartment for security services
- **`oci-core-deploy-SaaS-apps-comp/`**: Creates EPM compartment hierarchy (ARCS-Prod, ARCS-Test, Other-EPM)
- **`oci-core-deploy-IaaS-Root/`**: Creates IaaS compartments with zero quotas (locked down)
- **`oci-core-deploy-security/`**: CIS compliance automation - Cloud Guard, ONS notifications, 11 event rules
- **`oci-core-policies/`**: Consolidated policy management, quotas, and cost tracking tags

### Key Files

- **`deployment/terraform.tfvars`**: Configuration file (not in git) - copy from `terraform.tfvars.example`
- **`oci-core-deploy-groups/csv_groups.csv`**: Source of truth for IAM groups (43 groups)
- **`oci-core-deploy-security/cloudguard.tf`**: Cloud Guard configuration (CIS 4.14)
- **`oci-core-deploy-security/event_rules.tf`**: 11 event rules (CIS 4.3-4.12, 4.15)
- **`oci-core-policies/policies.tf`**: IAM policies for groups
- **`oci-core-policies/quotas.tf`**: Zero quotas for security
- **`oci-core-policies/tags.tf`**: Cost tracking tags (CostCenter, Environment, Application)

### Security Module Architecture

The security module implements CIS recommendations 4.2-4.15:

```
Root Compartment
├── Cloud Guard (enabled with Oracle-managed recipes)
├── 11 Event Rules (monitoring IAM, network, Cloud Guard events)
└── shared-services/
    └── security-notifications topic
        └── Email subscriptions (requires confirmation)
```

**Important**: Email subscriptions remain in "Pending" state until recipients click confirmation links.

## Important Development Patterns

### Adding New IAM Groups

1. Edit `oci-core-deploy-groups/csv_groups.csv`
2. Add line: `GroupName,Description,Environment,Owner`
3. Run `terraform plan` from `deployment/` to preview
4. Run `terraform apply` to create

### Modifying Security Notifications

Email addresses are configured in `deployment/terraform.tfvars`:

```hcl
security_notification_emails = [
  "security@company.com",
  "compliance@company.com"
]
```

After changing emails, run `terraform apply`. New subscribers receive confirmation emails.

### Enabling IaaS Infrastructure

Currently IaaS has zero quotas. To enable:

1. Update `oci-core-policies/quotas.tf` with desired limits
2. Set `enable_iaas_policies = true` in `deployment/terraform.tfvars`
3. Apply changes from `deployment/`

### Working with Compartments

Compartments use dependency chaining. When modifying:

- Never delete a compartment that has policies referencing it
- Check `depends_on` blocks in `deployment/main.tf`
- The policies module must always deploy last

### Handling State

- Terraform state is local (`deployment/terraform.tfstate`)
- **Never commit `terraform.tfstate` or `terraform.tfvars` to git**
- For team collaboration, consider configuring remote state backend in `deployment/provider.tf`

## CIS Compliance Context

This repository automates 13 of 22 failing CIS recommendations:

**Automated via Terraform**:
- CIS 4.2-4.12: Event monitoring and notifications
- CIS 4.14: Cloud Guard enabled
- CIS 4.15: Cloud Guard problem notifications

**Manual remediation required** (see `CIS_COMPLIANCE_IMPROVEMENTS.md`):
- CIS 1.6-1.16: Password policies, credential rotation, admin key management

**Expected outcome**: 50% reduction in failing CIS checks after automated deployment.

## Configuration Requirements

### Required Variables

In `deployment/terraform.tfvars` (copy from `terraform.tfvars.example`):

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaa..."
user_ocid        = "ocid1.user.oc1..aaaaaaaa..."
fingerprint      = "aa:bb:cc:dd:ee:ff:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"

# Required for CIS 4.2 compliance
security_notification_emails = [
  "security-team@company.com"
]
```

### OCI Authentication

The codebase uses OCI provider authentication via API key. Ensure:

1. OCI CLI is configured OR
2. API key files exist at `private_key_path`
3. User has required IAM permissions (manage cloud-guard, events, notifications, compartments, groups, policies)

## Troubleshooting

### "Compartment not found" errors

Check dependency order. Security module needs shared-services compartment. Policies module needs all compartments.

### Email subscriptions stuck in "Pending"

Recipients must click confirmation link in email. Check spam folders. Subscriptions expire after 7 days.

### Cloud Guard shows "Disabled"

Cloud Guard may take up to 1 hour for first-time activation. Check region availability.

### State lock errors

If `terraform apply` was interrupted, unlock state:

```bash
cd deployment
terraform force-unlock <LOCK_ID>
```

### Module dependency issues

If modules fail due to missing resources, ensure deployment order:
1. Groups → 2. Compartments → 3. Security → 4. Policies

## Tags and Cost Tracking

All resources are tagged with:
- **CostCenter**: Finance, IT, Operations, Shared
- **Environment**: Production, Test, Development, Staging, Parked
- **Application**: ARCS, Planning, EDMCS, Freeform, Infrastructure, Security

Tags are enforced via tag defaults on compartments. Modify valid values in `deployment/terraform.tfvars`.

## Resource Naming Conventions

- **Compartments**: lowercase-with-hyphens (e.g., `shared-services`, `ARCS-Prod`)
- **IAM Groups**: PascalCase or IAM_OCI_SECUREROLE_ prefix (e.g., `ARCS-Prod-Admins`, `IAM_OCI_SECUREROLE_EPM_PowerUsers`)
- **Event Rules**: `cis-<number>-<description>` (e.g., `cis-4.5-iam-group-changes`)
- **ONS Topics**: lowercase-with-hyphens (e.g., `security-notifications`)

## Version Requirements

- **Terraform**: >= 1.3.0 (currently using 1.13.3)
- **OCI Provider**: ~> 5.0 (currently using 7.21.0)
- **Python**: 3.x (for CIS compliance checker)

## Documentation References

- **Architecture**: `README.md` - Overview and high-level structure
- **Quick Start**: `QUICKSTART.md` - Step-by-step deployment guide
- **CIS Compliance**: `CIS_COMPLIANCE_IMPROVEMENTS.md` - Automated vs manual remediation
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md` - Detailed compliance implementation details
- **Module READMEs**: Each module directory has specific documentation
