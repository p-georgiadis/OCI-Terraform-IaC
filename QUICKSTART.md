# Quick Start Guide - CIS Compliance Deployment

This guide will help you quickly deploy the CIS compliance security infrastructure.

## Prerequisites

- [ ] Terraform 1.0 or higher installed
- [ ] OCI CLI configured or API key available
- [ ] Security team email addresses
- [ ] Appropriate OCI permissions (see below)

## Required OCI Permissions

Your user or service principal needs the following permissions:

```hcl
# In the root/tenancy compartment
Allow group <your-group> to manage cloud-guard-family in tenancy
Allow group <your-group> to manage cloudevents-rules in tenancy
Allow group <your-group> to manage alarms in tenancy
Allow group <your-group> to manage ons-topics in tenancy
Allow group <your-group> to manage ons-subscriptions in tenancy
Allow group <your-group> to read compartments in tenancy
```

## Step 1: Configure Terraform Variables

1. Copy the example variables file:
```bash
cd deployment
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` and update:
   - OCI authentication details (tenancy_ocid, user_ocid, etc.)
   - Security notification emails (REQUIRED)
   - Optional: Cloud Guard and notification settings

**Minimum Required Configuration:**
```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaa..."
user_ocid        = "ocid1.user.oc1..aaaaaaaa..."
fingerprint      = "aa:bb:cc:dd:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"

security_notification_emails = [
  "security@yourcompany.com"
]
```

## Step 2: Initialize Terraform

```bash
cd deployment
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/oci...

Terraform has been successfully initialized!
```

## Step 3: Review the Plan

```bash
terraform plan
```

Review the resources that will be created:
- 1 Cloud Guard configuration
- 1 Cloud Guard target
- 1 ONS notification topic
- N ONS email subscriptions (based on emails provided)
- 11 Event rules for security monitoring

## Step 4: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

Expected apply time: 2-5 minutes

## Step 5: Confirm Email Subscriptions

After deployment completes:

1. Each person in `security_notification_emails` will receive a confirmation email
2. Subject: "Subscription Confirmation"
3. **Action Required**: Click the confirmation link in each email
4. Subscriptions are not active until confirmed

## Step 6: Verify Deployment

### Verify Cloud Guard
```bash
# Via OCI Console
Navigate to: Security > Cloud Guard > Overview
# Should show: Status = ENABLED

# Via OCI CLI
oci cloud-guard configuration get --compartment-id <tenancy-ocid>
```

### Verify Notifications
```bash
# Via OCI Console
Navigate to: Application Integration > Notifications
# Should show: security-notifications topic with active subscriptions

# Via OCI CLI
oci ons topic list --compartment-id <shared-services-compartment-id>
```

### Verify Event Rules
```bash
# Via OCI Console
Navigate to: Observability > Events Service > Rules
# Should show: 11 rules with names starting with "cis-4."

# Via OCI CLI
oci events rule list --compartment-id <tenancy-ocid>
```

## Step 7: Test Notifications (Optional)

Create a test event to verify notifications are working:

```bash
# Create a test user (will trigger CIS 4.7 event rule)
oci iam user create \
  --name "test-user-delete-me" \
  --description "Test user for notification verification"

# Delete the test user
oci iam user delete --user-id <user-ocid> --force
```

Security team should receive email notification about user creation/deletion.

## Terraform Outputs

After successful deployment, review the outputs:

```bash
terraform output
```

Key outputs:
- `security_configuration`: Status of security services
- `cis_compliance_status`: List of CIS recommendations addressed
- `security_notification_topic`: Topic ID and name

## Troubleshooting

### Issue: "Service CloudGuard is not available"
**Solution**: Cloud Guard may not be available in your region. Contact Oracle Support.

### Issue: Email subscriptions stuck in "Pending"
**Solution**: Check spam folder for confirmation emails. Subscriptions expire after 7 days if not confirmed.

### Issue: "Insufficient permissions"
**Solution**: Verify your user has the required IAM policies (see prerequisites).

### Issue: Terraform state conflicts
**Solution**: If multiple people are deploying, use remote state:
```hcl
# Add to deployment/provider.tf
terraform {
  backend "s3" {
    # Configure OCI Object Storage backend
  }
}
```

## What's Next?

After deployment:

1. **Review Cloud Guard Findings**: Navigate to Security > Cloud Guard > Problems
2. **Monitor Notifications**: Watch for security event notifications
3. **Manual Remediation**: Follow steps in `CIS_COMPLIANCE_IMPROVEMENTS.md` for items that can't be automated
4. **Establish Processes**: Create operational procedures for:
   - Responding to Cloud Guard alerts
   - Reviewing security notifications
   - Quarterly access reviews
   - Credential rotation (90-day cycle)

## Additional Resources

- [CIS_COMPLIANCE_IMPROVEMENTS.md](../CIS_COMPLIANCE_IMPROVEMENTS.md) - Complete compliance guide
- [oci-core-deploy-security/README.md](../oci-core-deploy-security/README.md) - Security module documentation
- [OCI Cloud Guard Documentation](https://docs.oracle.com/en-us/iaas/cloud-guard/home.htm)
- [CIS Oracle Cloud Infrastructure Foundations Benchmark](https://www.cisecurity.org/benchmark/oracle_cloud)

## Support

For issues or questions:
1. Review the troubleshooting section above
2. Check Terraform and OCI provider logs
3. Consult OCI documentation
4. Contact your cloud infrastructure team
