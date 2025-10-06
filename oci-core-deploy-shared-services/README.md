# Shared Services Compartment Module

## Purpose
Creates a compartment for shared OCI services including Cloud Guard, logging, monitoring, and other security/governance services per TAD ICF2511.

## Architecture
```
Tenancy Root
└── shared-services (Container for shared infrastructure services)
    ├── (Future) Cloud Guard targets and configurations
    ├── (Future) Log groups and audit logs
    ├── (Future) Service Connector Hub for QRadar integration
    ├── (Future) Monitoring alarms and notifications
    └── (Future) Other security and governance services
```

## Scope
This module ONLY creates the empty compartment structure. It does NOT create the services themselves:
- IAM policies (will be managed in `oci-core-policies` module)
- Cloud Guard resources (will be managed in `oci-core-security` module when QRadar details are available)
- Logging resources (will be managed in `oci-core-security` module)
- Monitoring resources (will be managed in `oci-core-security` module)

The compartment must exist first before these services can be deployed into it.

## Usage

```hcl
module "shared_services" {
  source = "./oci-core-deploy-shared-services"
  
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  
  compartment_name        = "shared-services"
  compartment_description = "Container for shared OCI security and governance services"
}
```

## Resources Created
- 1 compartment at tenancy root level
- 60-second IAM propagation wait

## What Will Be Deployed Here Later
Once this compartment exists, the `oci-core-security` module will deploy:
- Cloud Guard targets for security posture management
- Centralized logging infrastructure for audit and compliance
- Service Connector Hub for streaming logs to QRadar SIEM
- Monitoring alarms for security events
- Vulnerability scanning configurations

## Inputs
See [variables.tf](./variables.tf) for full list.

## Outputs
- `compartment_id` - OCID of the compartment (needed by security module)
- `compartment_name` - Name of the compartment
- `compartment_path` - Full path of the compartment

## Deployment Order
1. Groups Module - Create IAM groups
2. **Shared Services Compartment** (this module) - Create the container
3. SaaS Compartments - Create application compartments
4. IaaS Compartments - Create infrastructure compartments
5. Policies Module - Create all IAM policies
6. Security Module (Future) - Deploy security services INTO this compartment

## Example
See [examples/complete](./examples/complete) for a working example.

## Requirements
- Terraform >= 1.3
- OCI Provider >= 6.0.0
