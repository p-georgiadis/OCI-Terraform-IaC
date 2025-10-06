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
| `oci-core-deploy-security` | Future: Cloud Guard, logging | Not yet implemented |

## Quick Start

### Prerequisites
- OCI tenancy with administrator access
- Terraform >= 1.3
- OCI CLI configured with credentials

### Deployment

```bash
cd deployment
# Edit terraform.tfvars with your OCI credentials

terraform init
terraform plan
terraform apply
```

This deploys all **76 resources** in the correct dependency order:
- **43 IAM Groups**
- **13 Compartments** 
- **9 IAM Policies**
- **3 Quota Policies**
- **1 Tag Namespace + 3 Tags**
- **4 Tag Defaults**
- **3 Time delays**

## Security & Compliance

### CIS Compliance
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
- ARCS production and test environments
- 43 IAM groups with role-based access
- Cost tracking tags (CostCenter, Environment, Application)
- Audit and compliance framework

### Reserved for Future
- IaaS infrastructure (zero quotas enforced)
- Cloud Guard and security services (pending QRadar integration)
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
1. Add users to appropriate groups
2. Run CIS compliance check and remediate findings
3. Configure ARCS application instances
4. When ready: Enable Cloud Guard and logging
5. Future: Activate IaaS when approved

## Support

For questions or issues:
- Review module-specific README files in each directory
- Check TAD ICF2511 for architecture requirements
- Consult Oracle CIS Foundations Benchmark v3.0.0


## Contributor

Panagiotis 'Pano' Georgiadis
