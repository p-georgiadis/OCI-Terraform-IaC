# OCI Security Module (Future Implementation)

## Status
**⚠️ NOT YET IMPLEMENTED** - This module is planned after QRadar integration details are finalized.

## Purpose
This module will automate the deployment and configuration of OCI security services for the Hanover EPM implementation, including Cloud Guard, logging infrastructure, and SIEM integration.

## Planned Components

### 1. Cloud Guard Configuration
- Enable Cloud Guard at tenancy level
- Configure Oracle-managed detector recipes
- Create target for root compartment with all child compartments
- Set up responder recipes for automated remediation
- Configure security zones for SaaS compartments

### 2. Logging Infrastructure
- Create log groups in shared-services compartment
- Enable audit log collection (required for compliance)
- Configure service logs for:
  - VCN Flow Logs
  - Object Storage access logs
  - Load Balancer access logs
  - API Gateway logs
- Set retention policies per compliance requirements

### 3. Service Connector Hub
- Stream logs to Hanover QRadar SIEM
- Configure event filtering rules
- Set up dead letter queue for failed deliveries

### 4. Monitoring and Alarms
- Create alarm topics
- Configure critical security alarms:
  - Unauthorized API calls
  - Root user activity
  - Policy changes
  - Network security changes

### 5. Vulnerability Scanning
- Enable vulnerability scanning service
- Configure scan recipes for compute instances
- Set up scan schedules

## Prerequisites Before Implementation

### Required Information:
1. **QRadar Integration Details**
   - Endpoint URL
   - Authentication method
   - Certificate requirements
   - Event format specifications
   - Network connectivity (FastConnect/IPSec)

2. **Compliance Requirements**
   - Log retention periods
   - Audit log requirements
   - Data residency constraints

3. **Security Team Input**
   - Alert thresholds
   - Responder recipe configurations
   - Security zone policies

## Temporary Manual Steps

Until this module is implemented, the following must be configured manually:

### 1. Enable Cloud Guard
1. Navigate to Cloud Guard in OCI Console
2. Enable Cloud Guard for the tenancy
3. Use Oracle-managed detector recipes
4. Create target for root compartment

### 2. Basic Logging
1. Go to Logging in shared-services compartment
2. Create log group: "default-log-group"
3. Enable audit logs for the tenancy
4. Set 365-day retention

### 3. Initial Monitoring
1. Create notification topic in shared-services
2. Subscribe security team email
3. Create basic alarms for critical events

## Module Structure (Planned)
```
oci-core-deploy-security/
├── main.tf              # Module orchestration
├── cloudguard.tf        # Cloud Guard configuration
├── logging.tf           # Log groups and logs
├── service_connector.tf # QRadar integration
├── monitoring.tf        # Alarms and notifications
├── scanning.tf          # Vulnerability scanning
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── README.md           # This file
└── examples/
    └── complete/       # Full deployment example
```

## Dependencies
This module will depend on:
- Compartments being created (shared-services, SaaS-Root, IaaS-Root)
- IAM groups existing
- Network infrastructure (if streaming through private endpoints)

## References
- [OCI Cloud Guard Documentation](https://docs.oracle.com/en-us/iaas/cloud-guard/home.htm)
- [OCI Logging Documentation](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm)
- [Service Connector Hub Documentation](https://docs.oracle.com/en-us/iaas/Content/service-connector-hub/home.htm)
- TAD Document ICF2511 Section 5.3 (Security Architecture)