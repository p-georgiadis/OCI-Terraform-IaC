# OCI Core Policies Module

## Purpose
Centralized management of all IAM policies, quotas, and tags for the Hanover EPM implementation per TAD ICF2511.

## Scope
This module consolidates all governance and access control including:
- IAM policies for all groups and compartments
- Quota policies to enforce zero-trust resource restrictions
- Tag namespaces and defaults for cost tracking and compliance
- CIS compliance support policies

## Prerequisites
The following must exist before deploying this module:
1. All IAM groups (created by oci-core-deploy-groups)
2. All compartments (shared-services, SaaS-Root, IaaS-Root, and sub-compartments)

## Resources Created
- **10 IAM Policies**:
  - Administrator policies
  - IAM administrator policies
  - Security administrator policies
  - EPM service administrator policies
  - EPM user policies
  - ARCS production/test admin policies
  - Finance auditor policies
  - CIS auditor policies
  - Network/Database admin policies (conditional)

- **3 Quota Policies**:
  - SaaS compartment restrictions (zero IaaS/PaaS resources)
  - IaaS compartment restrictions (zero resources until approved)
  - Shared services restrictions (limited to security services)

- **1 Tag Namespace**: "Operations"
- **3 Tags**: CostCenter, Environment, Application
- **4 Tag Defaults**: ARCS-Prod and ARCS-Test cost center/environment defaults

## Usage
```hcl
module "policies" {
  source = "../oci-core-policies"
  
  tenancy_ocid = var.tenancy_ocid
  
  # Group references
  iam_admin_group = "IAM_OCI_SECUREROLE_IAMAdmins"
  sec_admin_group = "IAM_OCI_SECUREROLE_SECAdmins"
  
  # Compartment dependencies
  depends_on = [
    module.shared_services,
    module.saas_compartments,
    module.iaas_compartments
  ]
  
  # Feature flags
  deploy_iaas_policies = false  # Enable when IaaS is ready
  deploy_arcs_policies = true   # ARCS policies are active
}
```

## Deployment Order
This module must be deployed LAST in the sequence:
1. Groups Module (oci-core-deploy-groups)
2. Shared Services Compartment
3. SaaS Compartments (including ARCS-Prod/Test)
4. IaaS Compartments
5. **Policies Module** (this module)

## Policy Details

### Administrative Policies
- **Administrators**: Full tenancy management (references pre-existing group)
- **IAM Admins**: User, group, policy, and compartment management
- **Security Admins**: Cloud Guard, logging, vaults in shared-services
- **CIS Auditors**: Read-only access for compliance checking

### EPM/ARCS Policies
- **EPM Service Administrators**: Manage EPM resources except environment creation
- **EPM Power Users**: Full EPM resource management
- **EPM Users**: Basic EPM access
- **ARCS-Prod Admins**: Production environment management
- **ARCS-Test Admins**: Test environment management
- **Finance Auditors**: Read-only access to SaaS resources

### Quota Restrictions
All compartments use zero-trust approach:
- **SaaS-Root**: Zero compute, database, networking, storage quotas
- **IaaS-Root**: Zero all resources (reserved for future use)
- **Shared-Services**: Limited to 1 VCN for Service Connector Hub

### Tag Structure
Enforced tags for cost tracking and compliance:
- **CostCenter**: Finance, IT, Operations, Shared
- **Environment**: Production, Test, Development, Staging, Parked
- **Application**: ARCS, Planning, EDMCS, Freeform, Infrastructure, Security

## Key Security Features
- Zero-trust by default (all resources blocked until explicitly allowed)
- CIS 3.0 compliance support through auditor policies
- Granular RBAC with 42 distinct groups
- Automatic tag enforcement for cost tracking
- EPM resource management using `epm-planning-environment-family`

## Notes
- EPM/ARCS policies use `epm-planning-environment-family` resource type
- Quota policies use service family names (e.g., `block-storage`, `compute-core`)
- Network and Database admin policies are conditional (deploy_iaas_policies flag)

## Requirements
- Terraform >= 1.3
- OCI Provider >= 6.0.0
