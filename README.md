# OCI-Hanover Infrastructure as Code

Terraform modules for deploying Hanover's Oracle Cloud Infrastructure (OCI) foundation per Technical Architecture Document (TAD) ICF2511.

## Overview

This repository contains modular Terraform code to deploy a CIS-compliant OCI tenancy structure for Hanover's EPM (Enterprise Performance Management) implementation, specifically focused on ARCS (Account Reconciliation Cloud Service).

## Architecture

```
Tenancy Root
├── shared-services/          # Security and governance services
├── SaaS-Root/               # EPM applications
│   ├── ARCS/
│   │   ├── ARCS-Prod/      # Production environment
│   │   └── ARCS-Test/      # Test/UAT environment
│   └── Other-EPM/           # Reserved for future EPM modules
│       ├── Planning/
│       ├── EDMCS/
│       └── Freeform/
└── IaaS-Root/               # Future infrastructure (locked down)
    ├── Network/
    ├── Applications/
    └── Database/
```

## Modules

| Module | Purpose | Resources Created |
|--------|---------|------------------|
| `oci-core-deploy-groups` | IAM groups from CSV | 43 groups including ARCS roles |
| `oci-core-deploy-shared-services` | Security services compartment | 1 compartment |
| `oci-core-deploy-SaaS-apps-comp` | EPM application compartments | 8 compartments |
| `oci-core-deploy-IaaS-Root` | Future infrastructure structure | 4 compartments (empty) |
| `oci-core-policies` | Consolidated policies and governance | 9 policies, 3 quotas, tags |
| `oci-core-deploy-security` | **NEW:** Cloud Guard, monitoring, notifications | Cloud Guard + 1 topic + 11 event rules |

## Quick Start

### Prerequisites

- OCI tenancy with administrator access
- Terraform >= 1.3
- OCI CLI configured with credentials
- Email addresses for security notifications (required for CIS compliance)

### Deployment

**📘 See [QUICKSTART.md](./QUICKSTART.md) for detailed deployment instructions**

```bash
cd deployment

# 1. Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCI credentials and security team emails

# 2. Deploy infrastructure
terraform init
terraform plan
terraform apply
```

This deploys **90+ resources** in the correct dependency order:

- **43 IAM Groups**
- **13 Compartments**
- **9 IAM Policies**
- **3 Quota Policies**
- **1 Tag Namespace + 3 Tags**
- **4 Tag Defaults**
- **1 Cloud Guard Configuration + Target**
- **1 Security Notification Topic + Subscriptions**
- **11 Event Rules for Security Monitoring**
- **3 Time delays**

## Security & Compliance

### CIS Benchmark Compliance ✅

**NEW: Automated CIS Compliance Module**

This repository now includes automated deployment of CIS OCI Foundation Benchmark security controls:

📋 **[CIS_COMPLIANCE_IMPROVEMENTS.md](./CIS_COMPLIANCE_IMPROVEMENTS.md)** - Complete guide to CIS compliance improvements

**Implemented via Terraform (13 CIS Recommendations):**

- ✅ **4.2** - Notification topic and subscriptions for security alerts
- ✅ **4.3-4.12** - Event rules monitoring IAM and network changes
- ✅ **4.14** - Cloud Guard enabled in root compartment
- ✅ **4.15** - Cloud Guard problem notifications

**Impact:** Reduces failing CIS checks by ~50%

**Additional Manual Steps Required:** See [CIS_COMPLIANCE_IMPROVEMENTS.md](./CIS_COMPLIANCE_IMPROVEMENTS.md) for credential rotation, password policies, and other operational items.

### Existing Security Features

- Groups configured for least privilege access
- Compartment isolation following CIS guidelines
- Zero quotas preventing unauthorized resource creation
- CIS-Auditors group for compliance checking

### Run Compliance Check in Cloud Shell

```bash
wget https://raw.githubusercontent.com/oci-landing-zones/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
python3 cis_reports.py -dt --all-resources
```

### Zero Trust Model

- All compartments start with zero quotas
- Explicit policies required for any resource creation
- Network/Database/Compute locked until approved

## Current State

### Active

- ✅ ARCS production and test environments
- ✅ 43 IAM groups with role-based access
- ✅ Cost tracking tags (CostCenter, Environment, Application)
- ✅ Audit and compliance framework
- ✅ **NEW: Cloud Guard security monitoring**
- ✅ **NEW: Event-based security notifications**
- ✅ **NEW: CIS-compliant monitoring infrastructure**

### Reserved for Future

- IaaS infrastructure (zero quotas enforced)
- Advanced logging and SIEM integration (pending QRadar configuration)
- Other EPM modules (Planning, EDMCS, Freeform)

## Module Details

### Groups Module (`oci-core-deploy-groups`)

Reads from `csv_groups.csv` to create 43 IAM groups:

- **7 Administrative groups**: CIS-Auditors, Administrators, NetworkAdmins, DBAdmins, IAMAdmins, SECAdmins, EPM_Admins
- **5 Finance/Audit groups**: Finance-Auditors, Finance_ReadOnly, ARCS-Prod-Admins, ARCS-Test-Admins, ARCS_Users  
- **4 EPM Service groups**: ServiceAdministrators, PowerUsers, Users, Viewer
- **27 ARCS functional roles**: Granular permissions for reconciliation, data integration, reporting, etc.

### Compartments

- **shared-services**: Future home of Cloud Guard, logging, monitoring
- **SaaS-Root**: All EPM applications with environment separation
- **IaaS-Root**: Prepared structure for future infrastructure

### Policies Module (`oci-core-policies`)

Centralizes all governance:

- IAM policies for group permissions
- Quota policies (zero quotas for security)
- Tag namespace and cost tracking

### Security Module (`oci-core-deploy-security`) ⭐ NEW

Implements CIS compliance security controls:

- **Cloud Guard**: Enabled with Oracle-managed detector recipes monitoring entire tenancy
- **Notifications**: Centralized security notification topic with email subscriptions
- **Event Monitoring**: 11 event rules tracking IAM, network, and Cloud Guard changes
- **CIS Coverage**: Addresses 13 CIS OCI Foundation Benchmark recommendations (4.2-4.15)

See [oci-core-deploy-security/README.md](./oci-core-deploy-security/README.md) for detailed documentation.

## Customization

### Adding New Groups

1. Edit `oci-core-deploy-groups/csv_groups.csv`
2. Re-run deployment

### Enabling IaaS (Future)

1. Update quotas in `oci-core-policies/quotas.tf`
2. Set `enable_iaas_policies = true` in deployment

### Adding EPM Modules

The structure supports adding Planning, EDMCS, or Freeform by moving them from "Parked" status.

## Repository Structure

```
OCI-Hanover/
├── deployment/              # Central deployment orchestration
├── oci-core-deploy-groups/  # IAM groups module
├── oci-core-deploy-shared-services/  # Security compartment
├── oci-core-deploy-SaaS-apps-comp/   # EPM compartments
├── oci-core-deploy-IaaS-Root/        # Future IaaS structure
├── oci-core-policies/       # All policies and governance
└── oci-core-deploy-security/         # Future security services
```

## Next Steps

After deployment:

1. **Confirm email subscriptions** - Security team must click confirmation links
2. **Add users to appropriate groups** - Assign IAM group memberships
3. **Review Cloud Guard findings** - Navigate to Security > Cloud Guard in OCI Console
4. **Run CIS compliance check** - Verify improvements with updated scan
5. **Complete manual remediation** - Follow steps in [CIS_COMPLIANCE_IMPROVEMENTS.md](./CIS_COMPLIANCE_IMPROVEMENTS.md)
6. **Configure ARCS applications** - Deploy EPM instances
7. **Future: Activate IaaS** when approved for use

## Documentation

- 📘 [QUICKSTART.md](./QUICKSTART.md) - Step-by-step deployment guide
- 📋 [CIS_COMPLIANCE_IMPROVEMENTS.md](./CIS_COMPLIANCE_IMPROVEMENTS.md) - Complete CIS compliance guide
- 🔒 [oci-core-deploy-security/README.md](./oci-core-deploy-security/README.md) - Security module details
- 📝 Module-specific README files in each directory

## Support

For questions or issues:

- 📘 Check [QUICKSTART.md](./QUICKSTART.md) for deployment guidance
- 📋 Review [CIS_COMPLIANCE_IMPROVEMENTS.md](./CIS_COMPLIANCE_IMPROVEMENTS.md) for compliance information
- 📝 Consult module-specific README files in each directory
- 📖 Reference TAD ICF2511 for architecture requirements
- 🔍 Refer to Oracle CIS Foundations Benchmark v3.0.0

## Contributor

Panagiotis 'Pano' Georgiadis
