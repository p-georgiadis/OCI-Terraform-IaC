# IaaS-Root Compartment Module

## Purpose
Creates a CIS-compliant compartment structure for future infrastructure workloads per TAD ICF2511.

## Architecture

### Created Structure (Empty - Reserved for Future Use)
```
Tenancy Root
└── IaaS-Root
    ├── Network (VCNs, Subnets, Load Balancers - Future)
    ├── Applications (Compute, Containers, Functions - Future)
    └── Database (Autonomous DB, MySQL, NoSQL - Future)
```

### Optional Enhanced Structure (When Enabled)
```
Tenancy Root
└── IaaS-Root
    ├── Network
    ├── Applications
    │   ├── Prod
    │   └── Non-Prod
    └── Database
```

## CIS Compliance Features

This module follows Oracle CIS Foundations Benchmark:
- **Network Isolation**: Separate compartment for all network resources
- **Database Isolation**: Separate compartment for all database resources  
- **Application Segregation**: Dedicated compartment for compute workloads
- **Environment Separation**: Optional prod/non-prod split
- **Ready for Zero-Trust**: Structure supports microsegmentation

## Current State

The module creates the compartment structure but:
- NO resources are deployed in any compartment
- NO networking is configured
- NO compute instances are created
- NO databases are provisioned
- Structure is ready for future resource deployment

## Usage

### Basic (Current Implementation)
```hcl
module "iaas_root" {
  source = "./oci-core-deploy-IaaS-Root"
  
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
```

This creates:
- IaaS-Root compartment
- Network sub-compartment (empty)
- Applications sub-compartment (empty)
- Database sub-compartment (empty)

## Resources Created
- 4 compartments total (1 root + 3 sub-compartments)
- All marked with "Reserved-Future-Use" status
- 60-second IAM propagation wait

## Outputs
- `iaas_root_compartment_id` - Root compartment OCID
- `network_compartment_id` - Network compartment OCID
- `applications_compartment_id` - Applications compartment OCID
- `database_compartment_id` - Database compartment OCID
- `compartment_tree` - Structure summary

## Future Resource Placement

When ready to deploy infrastructure:

### Network Compartment Will Contain:
- Virtual Cloud Networks (VCNs)
- Subnets (public/private)
- Internet/NAT/Service Gateways
- Load Balancers
- DRG for connectivity

### Applications Compartment Will Contain:
- Compute instances
- Container Engine (OKE)
- Functions
- API Gateway
- Object Storage for apps

### Database Compartment Will Contain:
- Autonomous Databases
- MySQL HeatWave
- NoSQL databases
- Database backups

## Requirements
- Terraform >= 1.3
- OCI Provider >= 6.0.0
