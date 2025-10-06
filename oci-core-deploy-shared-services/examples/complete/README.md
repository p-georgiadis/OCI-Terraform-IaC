# Shared Services Compartment Example

This example creates the shared-services compartment for centralized OCI services.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What Gets Created
- One compartment named "shared-services" at tenancy root
- 60-second IAM propagation wait

## Purpose
This compartment will house:
- Cloud Guard configuration
- Logging infrastructure
- Monitoring and alarms
- Service Connector Hub (for QRadar)
- Other shared security services