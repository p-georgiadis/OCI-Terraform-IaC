# OCI Core Policies Module

## Purpose
Centralized management of all IAM policies, quotas, and tags for the Hanover EPM implementation per TAD ICF2511.

## Scope
This module consolidates all governance and access control including:
- IAM policies for all groups and compartments
- Quota policies to restrict resource creation
- Tag namespaces and defaults for cost tracking and compliance

## Prerequisites
The following must exist before deploying this module:
1. All IAM groups (created by oci-core-deploy-groups)
2. All compartments (shared-services, SaaS-Root, IaaS-Root)

## Resources Created
- 8-10 IAM policies
- 1-2 Quota policies
- 1 Tag namespace
- 3 Tags (CostCenter, Environment, Application)
- 4 Tag defaults (ARCS-Prod and ARCS-Test)

## Usage
```hcl
module "policies" {
  source = "./oci-core-policies"
  
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  
  # Enable IaaS policies when ready
  deploy_iaas_policies = false
}
```

## Deployment Order
This module must be deployed LAST:
1. Groups Module
2. Shared Services Compartment
3. SaaS Compartments
4. IaaS Compartments
5. **Policies Module** (this module)

## Policy Summary

### Administrative Policies
- Administrators: Full tenancy management
- IAM Admins: User, group, policy, and compartment management
- Security Admins: Security services in shared-services

### EPM Policies
- Service Administrators: EPM service management
- ARCS Admins: Environment-specific management
- EPM Users: Basic EPM access
- Auditors: Read-only access

### Resource Restrictions
- Zero quotas for IaaS/PaaS in SaaS compartments
- Conditional statements preventing unauthorized resource creation

## Requirements
- Terraform >= 1.3
- OCI Provider >= 6.0.0
