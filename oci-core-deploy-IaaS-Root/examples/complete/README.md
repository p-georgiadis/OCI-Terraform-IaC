# IaaS-Root Compartment Example

This example creates the IaaS compartment structure for future infrastructure deployment.

## What Gets Created

```
IaaS-Root/
├── Network/      (Empty - for future VCNs, subnets, gateways)
├── Applications/ (Empty - for future compute, containers)
└── Database/     (Empty - for future databases)
```

All compartments are created empty and tagged as "Reserved-Future-Use".

## Usage

```bash
# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials

# Deploy
terraform init
terraform plan
terraform apply
```

## Outputs

The module provides OCIDs for all created compartments:
- Root IaaS compartment
- Network compartment
- Applications compartment
- Database compartment

## Notes

- No actual infrastructure resources are created
- Compartments are ready for future resource deployment
- Structure follows CIS compliance recommendations
- Can optionally enable prod/non-prod separation under Applications

## Next Steps

After creating this structure:
1. Apply the policies module to set permissions
2. When ready, deploy network resources to Network compartment
3. Deploy applications to Applications compartment
4. Deploy databases to Database compartment