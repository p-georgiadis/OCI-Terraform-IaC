# OCI Security Module

## Status
**✅ IMPLEMENTED** - Core CIS compliance features for monitoring and alerting

## Purpose
This module automates the deployment and configuration of OCI security services to meet CIS Benchmark compliance requirements, including Cloud Guard, event monitoring, and notification infrastructure.

## Implemented Components

### 1. Cloud Guard Configuration ✅
**CIS Recommendation 4.14**
- Enables Cloud Guard at tenancy level
- Uses Oracle-managed detector recipes (Configuration, Activity, Threat)
- Creates target for root compartment monitoring entire tenancy
- Supports custom detector and responder recipes

### 2. Notification Infrastructure ✅
**CIS Recommendation 4.2**
- Creates security notification topic in shared-services compartment
- Supports multiple email subscriptions for security team
- Foundation for all security event notifications

### 3. Event Rules for Security Monitoring ✅
**CIS Recommendations 4.3-4.12, 4.15**
- **4.3**: Identity Provider changes
- **4.4**: IdP Group Mapping changes
- **4.5**: IAM Group changes
- **4.6**: IAM Policy changes
- **4.7**: User changes
- **4.8**: VCN changes
- **4.9**: Route Table changes
- **4.10**: Security List changes
- **4.11**: Network Security Group changes
- **4.12**: Network Gateway changes (DRG, IGW, NAT, Service Gateway)
- **4.15**: Cloud Guard Problems (detected, dismissed, remediated)

## Future Enhancements

### Logging Infrastructure (Planned)
- Create log groups in shared-services compartment
- Enable audit log collection
- Configure VCN Flow Logs
- Configure Object Storage access logs
- Set retention policies per compliance requirements

### Service Connector Hub (Pending QRadar Details)
- Stream logs to SIEM
- Configure event filtering rules
- Set up dead letter queue for failed deliveries

## Prerequisites

1. **Compartments** - Shared-services compartment must exist
2. **IAM Permissions** - User/principal must have permissions to:
   - Manage Cloud Guard configuration
   - Create notification topics and subscriptions
   - Create event rules
3. **Email Addresses** - Valid email addresses for security team notifications

## Usage

### Basic Example

```hcl
module "security" {
  source = "../oci-core-deploy-security"

  depends_on = [
    module.shared_services
  ]

  # Tenancy OCID and region (needed for Cloud Guard)
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  # Required: Shared Services Compartment
  shared_services_compartment_id = module.shared_services.compartment_id

  # Security Team Notifications
  security_notification_emails = [
    "security-team@example.com",
    "compliance@example.com"
  ]

  # Optional: Custom naming
  notification_topic_name = "security-notifications"
  cloud_guard_target_name = "root-compartment-target"

  # Optional: Enable Cloud Guard self-management
  cloud_guard_self_manage_resources = false
}
```

**Note**: This module inherits the OCI provider configuration from the parent module, so you don't need to pass provider authentication variables.

### Complete Example with Custom Recipes

```hcl
module "security" {
  source = "../oci-core-deploy-security"

  depends_on = [
    module.shared_services
  ]

  tenancy_ocid                   = var.tenancy_ocid
  region                         = var.region
  shared_services_compartment_id = module.shared_services.compartment_id

  security_notification_emails = ["security@example.com"]

  # Use custom detector recipes (optional)
  cloud_guard_configuration_detector_recipe_id = "ocid1.cloudguarddetectorrecipe...."
  cloud_guard_activity_detector_recipe_id      = "ocid1.cloudguarddetectorrecipe...."
  cloud_guard_threat_detector_recipe_id        = "ocid1.cloudguarddetectorrecipe...."
  cloud_guard_responder_recipe_id              = "ocid1.cloudguardresponderrecipe...."

  # Allow Cloud Guard to auto-remediate issues
  cloud_guard_self_manage_resources = true

  # Custom tags
  freeform_tags = {
    Environment = "Production"
    CostCenter  = "Security"
    Purpose     = "CIS-Compliance"
  }
}
```

## Module Structure
```
oci-core-deploy-security/
├── main.tf              # Module orchestration and provider configuration
├── cloudguard.tf        # Cloud Guard configuration (CIS 4.14)
├── notifications.tf     # ONS topics and subscriptions (CIS 4.2)
├── event_rules.tf       # Event monitoring rules (CIS 4.3-4.12, 4.15)
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── versions.tf          # Terraform and provider versions
└── README.md            # This file
```

## CIS Compliance Coverage

This module addresses the following CIS OCI Foundation Benchmark v2.0.0 recommendations:

| CIS # | Recommendation | Status |
|-------|----------------|--------|
| 4.2 | Create notification topic and subscription | ✅ Implemented |
| 4.3 | Notification for Identity Provider changes | ✅ Implemented |
| 4.4 | Notification for IdP group mapping changes | ✅ Implemented |
| 4.5 | Notification for IAM group changes | ✅ Implemented |
| 4.6 | Notification for IAM policy changes | ✅ Implemented |
| 4.7 | Notification for user changes | ✅ Implemented |
| 4.8 | Notification for VCN changes | ✅ Implemented |
| 4.9 | Notification for route table changes | ✅ Implemented |
| 4.10 | Notification for security list changes | ✅ Implemented |
| 4.11 | Notification for NSG changes | ✅ Implemented |
| 4.12 | Notification for network gateway changes | ✅ Implemented |
| 4.14 | Enable Cloud Guard in root compartment | ✅ Implemented |
| 4.15 | Notification for Cloud Guard problems | ✅ Implemented |

## Important Notes

### Email Subscription Confirmation
After deployment, email subscribers will receive a confirmation email from Oracle Notifications Service. They must click the confirmation link to activate the subscription.

### Cloud Guard First-Time Setup
If this is the first time enabling Cloud Guard in the tenancy:
1. It may take up to 1 hour for initial data collection
2. Oracle-managed detector recipes are automatically enabled
3. The root compartment target monitors all child compartments

### Event Rule Scope
All event rules are created at the tenancy (root) level to capture events from all compartments, following CIS best practices.

## Dependencies
- **shared-services compartment** must exist before deploying this module
- Must be deployed after compartment modules

## References
- [CIS Oracle Cloud Infrastructure Foundations Benchmark](https://www.cisecurity.org/benchmark/oracle_cloud)
- [OCI Cloud Guard Documentation](https://docs.oracle.com/en-us/iaas/cloud-guard/home.htm)
- [OCI Events Documentation](https://docs.oracle.com/en-us/iaas/Content/Events/home.htm)
- [OCI Notifications Documentation](https://docs.oracle.com/en-us/iaas/Content/Notification/home.htm)