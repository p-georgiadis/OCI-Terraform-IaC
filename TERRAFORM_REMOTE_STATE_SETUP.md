# Terraform Remote State Setup Guide
## OCI Object Storage Backend Configuration

**Last Updated:** 2025-10-31
**Author:** Panagiotis 'Pano' Georgiadis
**Environment:** Generic - Applicable to any OCI Tenancy

---

## Executive Summary

This guide provides comprehensive instructions for setting up Terraform state management in OCI Object Storage using **OCI's native backend**, which is the recommended approach by Oracle.

**Target State:**
- **New deployment** - No existing local state file
- Remote state storage in OCI Object Storage at tenancy level
- Clean start with remote backend from day one
- Terraform version: 1.12.0+
- **Native OCI backend** - uses your existing OCI CLI configuration

**Benefits of Remote State:**
- Centralized state storage with team collaboration support
- Automatic state locking to prevent concurrent modifications
- State file versioning and disaster recovery
- Enhanced security with OCI IAM and encryption
- Audit logging of all state access
- CIS compliance alignment (encryption, logging, access control)
- **Simple authentication** - uses existing OCI CLI credentials

**Approach:** Manual bucket creation (bootstrap separation pattern) with OCI native backend

**Implementation Timeline:** 1-2 hours
**Risk Level:** Low (with proper backup and rollback plan)

---

## Quick Reference (For Experienced Users)

If you've set up remote state before and just need a reminder:

```bash
# 1. Create bucket at tenancy level
export TENANCY_OCID=$(grep 'tenancy_ocid' deployment/terraform.tfvars | cut -d'"' -f2)
export NAMESPACE=$(oci os ns get --query "data" --raw-output)
export REGION=$(grep 'region' deployment/terraform.tfvars | cut -d'"' -f2)
oci os bucket create --compartment-id "$TENANCY_OCID" --name "terraform-state" \
  --versioning Enabled --public-access-type NoPublicAccess --region "$REGION"

# 2. Create service policy for lifecycle
HOME_REGION=$(oci iam region-subscription list --query 'data[?"is-home-region"==`true`]."region-name" | [0]' --raw-output)
oci iam policy create --compartment-id "$TENANCY_OCID" --name "objectstorage-lifecycle-service-policy" \
  --statements "[\"Allow service objectstorage-${HOME_REGION} to manage object-family in tenancy where target.bucket.name='terraform-state'\"]"

# 3. Apply lifecycle policy (see Step 3 for JSON)

# 4. Get your namespace and region for backend.tf
echo "Namespace: $NAMESPACE"
echo "Region: $REGION"

# 5. Update deployment/backend.tf with your namespace and region

# 6. Initialize: terraform init (uses your ~/.oci/config automatically!)
cd deployment
terraform init
```

**For detailed explanations, see the full guide below.**

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Manual Bootstrap Approach](#manual-bootstrap-approach)
3. [OCI Infrastructure Setup](#oci-infrastructure-setup)
4. [Terraform Backend Configuration](#terraform-backend-configuration)
5. [Deployment Procedure](#deployment-procedure)
6. [Daily Operations](#daily-operations)
7. [Testing and Validation](#testing-and-validation)
8. [Troubleshooting](#troubleshooting)
9. [Security and Compliance](#security-and-compliance)
10. [References](#references)
11. [Appendix: Quick Reference](#appendix-quick-reference)

---

## Prerequisites

### Working Directory

**IMPORTANT:** All commands in this guide assume you are running from your **project root directory** (where your `deployment/` folder is located).

```bash
# Verify you're in the correct location
ls deployment/terraform.tfvars  # Should exist

# If not, navigate to your project root first
cd /path/to/your/terraform/project
```

### Required Access

- [ ] OCI tenancy administrator access or equivalent permissions
- [ ] Ability to create Object Storage buckets at tenancy level
- [ ] **Ability to create IAM policies at tenancy level (CRITICAL for service policy)**
- [ ] Current working Terraform deployment (able to run `terraform plan`)

### Required Tools

- [ ] Terraform >= 1.12.0 (for OCI native backend support)
- [ ] OCI CLI configured with valid credentials
- [ ] Valid OCI CLI configuration at ~/.oci/config

### OCI CLI Configuration

Ensure your OCI CLI is properly configured:

```bash
# Verify OCI CLI is configured
oci os ns get

# Expected output: Your Object Storage namespace
# If this fails, run: oci setup config
```

### Environment Variables

Ensure these are available (typically in `deployment/terraform.tfvars`):

```hcl
tenancy_ocid         = "ocid1.tenancy.oc1..xxxxx"
user_ocid            = "ocid1.user.oc1..xxxxx"
fingerprint          = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path     = "/path/to/oci_api_key.pem"
private_key_password = ""  # if key is encrypted
region               = "your-region"  # e.g., us-ashburn-1, eu-frankfurt-1, etc.
```

---

## Manual Bootstrap Approach

### Philosophy: Foundational vs Managed Infrastructure

We treat infrastructure in two tiers:

**Tier 0: Foundational Infrastructure (Manual)**
- Created once, rarely changes
- Required for Terraform itself to function
- Examples: State bucket, CI/CD service accounts, root monitoring
- Managed outside Terraform or in separate bootstrap project

**Tier 1: Managed Infrastructure (Terraform)**
- Your 90+ resources in deployment/
- All application and platform infrastructure
- State stored in Tier 0 infrastructure

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     OCI Tenancy (Root Level)                │
│                                                             │
│  ┌──────────────────────────────────────────┐              │
│  │  TIER 0: FOUNDATIONAL                    │              │
│  │  Object Storage Bucket                   │              │
│  │  Name: terraform-state                   │              │
│  │  Location: TENANCY LEVEL (not in any compartment) │    │
│  │  Created: OCI CLI (manual)               │              │
│  │  Managed: Never destroyed                │              │
│  │                                           │              │
│  │  Features:                                │              │
│  │  • Versioning: Enabled                    │              │
│  │  • Encryption: AES-256                    │              │
│  │  • Public Access: Disabled                │              │
│  │  • Lifecycle: 90-day retention            │              │
│  │  • Protection: IAM policies + tags        │              │
│  │                                           │              │
│  │  Contains:                                │              │
│  │  • deployment.tfstate (231 KB)           │              │
│  │  • deployment.tfstate.lock               │              │
│  │  • versions/ (automatic)                 │              │
│  └──────────────────────────────────────────┘              │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │  Compartment: shared-services                      │   │
│  │  (Created by Terraform)                            │   │
│  │                                                     │   │
│  │  ┌──────────────────────────────────────────┐     │   │
│  │  │  TIER 1: MANAGED INFRASTRUCTURE          │     │   │
│  │  │  • Compartments                           │     │   │
│  │  │  • IAM Groups & Policies                  │     │   │
│  │  │  • Cloud Guard                            │     │   │
│  │  │  • Networking                             │     │   │
│  │  │  • Security services                      │     │   │
│  │  │  • 90+ resources total                    │     │   │
│  │  │                                           │     │   │
│  │  │  Managed by: deployment/ Terraform       │     │   │
│  │  │  State stored: terraform-state bucket    │     │   │
│  │  └──────────────────────────────────────────┘     │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

         ▲                           ▲
         │                           │
    ┌────┴──────┐             ┌─────┴──────┐
    │ IAMAdmins │             │ CI/CD      │
    │ Group     │             │ Pipeline   │
    └───────────┘             └────────────┘
         │                           │
         └───────────────┬───────────┘
                         │
           Uses ~/.oci/config for authentication
           (OCI native backend - no AWS credentials!)
```

### Benefits of This Approach

This manual bootstrap approach with OCI native backend provides:

1. **No Destroy Risk** - Bucket cannot be accidentally destroyed by `terraform destroy`
2. **Clear Separation** - Foundational vs managed infrastructure is explicit
3. **Simplicity** - Easy to understand and explain to team
4. **Native Authentication** - Uses existing OCI CLI configuration (no extra credentials)
5. **Team-Friendly** - Each team member uses their own OCI credentials
6. **Auditability** - Clear separation between "bootstrap" and "operational" changes
7. **Recovery** - If Terraform state is lost, foundational infrastructure remains intact
8. **Industry Standard** - Similar to AWS, Azure, GCP approaches

The bucket is created once manually and then becomes foundational infrastructure that supports all Terraform operations.

---

## OCI Infrastructure Setup

### Step 1: Bucket Placement Decision - Tenancy Level

> **⚠️ CRITICAL: Why Tenancy Level is Required**
>
> For **new deployments**, the state bucket MUST be at the **tenancy (root) level**, not in any compartment.
>
> **Why?**
> - Your Terraform code **creates** the `shared-services` compartment
> - On first deployment, `shared-services` doesn't exist yet
> - You cannot create a bucket in a non-existent compartment
> - The state bucket must exist BEFORE Terraform runs
> - Therefore: **Bucket at tenancy level** (which always exists)

**Compartment vs Tenancy Level:**

| Approach | Works for New Deployment? | CIS 2.1 Compliant? | Recommended? |
|----------|---------------------------|-------------------|--------------|
| **Tenancy level** | ✅ Yes - always exists | ⚠️ Exception allowed | **✅ YES** |
| Compartment level | ❌ No - doesn't exist yet | ✅ Yes | ❌ NO |

**CIS 2.1 Exception:**
- CIS 2.1: "Ensure no resources are created in the root compartment"
- **Exception:** Bootstrap/foundational infrastructure (state storage)
- Industry standard: AWS, Azure, GCP all use root level for state storage
- Documented as foundational infrastructure exception

**Get Tenancy OCID:**

```bash
# Get tenancy OCID from terraform.tfvars
export TENANCY_OCID=$(grep 'tenancy_ocid' deployment/terraform.tfvars | cut -d'"' -f2)

# Verify
echo "Tenancy OCID: $TENANCY_OCID"

# Alternative: Use OCI CLI
# export TENANCY_OCID=$(oci iam compartment list --compartment-id-in-subtree false --query 'data[0]."compartment-id"' --raw-output)
```

**Expected Output:**
```
ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Save this OCID - you'll need it for all subsequent steps.

### Step 2: Create Object Storage Bucket at Tenancy Level (MANUAL - FOUNDATIONAL TIER)

> **IMPORTANT: This is manual creation by design**
>
> This bucket is **NOT** managed by Terraform in your deployment/ directory.
> It is foundational infrastructure created once and protected from Terraform lifecycle.
>
> **Created at TENANCY level** - not in any compartment, because compartments don't exist yet!

**Get Object Storage Namespace:**

```bash
# Get your tenancy's Object Storage namespace
export NAMESPACE=$(oci os ns get --query "data" --raw-output)
echo "Object Storage Namespace: $NAMESPACE"

# Save this value - you'll need it for backend.tf configuration
```

**Set Required Variables:**

```bash
# Set variables for bucket creation
export TENANCY_OCID=$(grep 'tenancy_ocid' deployment/terraform.tfvars | cut -d'"' -f2)
export REGION=$(grep 'region' deployment/terraform.tfvars | cut -d'"' -f2)
export BUCKET_NAME="terraform-state"

# Verify variables
echo "Tenancy OCID: $TENANCY_OCID"
echo "Region: $REGION"
echo "Bucket Name: $BUCKET_NAME"
echo "Namespace: $NAMESPACE"
```

**Create the Bucket:**

```bash
# Create bucket with versioning and security settings
oci os bucket create \
  --compartment-id "$TENANCY_OCID" \
  --name "$BUCKET_NAME" \
  --versioning Enabled \
  --public-access-type NoPublicAccess \
  --storage-tier Standard \
  --freeform-tags '{
    "Purpose":"Terraform Remote State Storage",
    "ManagedBy":"Manual",
    "ProtectionLevel":"Critical",
    "DoNotDelete":"true"
  }' \
  --region "$REGION"
```

**Verify Bucket Creation:**

```bash
# Check bucket details
oci os bucket get \
  --bucket-name "$BUCKET_NAME" \
  --namespace-name "$NAMESPACE" \
  --query "data.{
    name:name,
    versioning:versioning,
    access:\"public-access-type\",
    tier:\"storage-tier\",
    compartment:\"compartment-id\"
  }"

# Expected output:
# {
#   "access": "NoPublicAccess",
#   "compartment": "ocid1.compartment.oc1..xxx",
#   "name": "terraform-state",
#   "tier": "Standard",
#   "versioning": "Enabled"
# }
```

### Step 3: Create Service Policy for Lifecycle Rules

> **⚠️ CRITICAL: This Must Be Done Before Applying Lifecycle Policy**
>
> The Object Storage **service** needs an IAM policy to execute lifecycle rules.
> Without this, lifecycle rules will appear to be created but **never execute** (silent failure).

```bash
# Get home region for service policy (must match exact region identifier)
HOME_REGION=$(oci iam region-subscription list \
  --query 'data[?"is-home-region"==`true`]."region-name" | [0]' \
  --raw-output)

echo "Home Region: $HOME_REGION"
echo "Service Principal: objectstorage-${HOME_REGION}"

# Create service policy (note: double quotes allow variable expansion)
oci iam policy create \
  --compartment-id "$TENANCY_OCID" \
  --name "objectstorage-lifecycle-service-policy" \
  --description "Allow Object Storage service to manage lifecycle policies on terraform-state bucket" \
  --statements "[\"Allow service objectstorage-${HOME_REGION} to manage object-family in tenancy where target.bucket.name='terraform-state'\"]" \
  --freeform-tags '{
    "Purpose":"Object Storage Lifecycle Management",
    "ManagedBy":"Manual"
  }'

# Verify policy was created
oci iam policy list --compartment-id "$TENANCY_OCID" \
  --name "objectstorage-lifecycle-service-policy" \
  --query "data[0].{name:name, statements:statements}"
```

> **Note:** This is a SERVICE policy, not a user/group policy. The service name format is `objectstorage-{region}`.
> For eu-frankfurt-1, it's `objectstorage-eu-frankfurt-1`.

### Step 4: Apply Lifecycle Policy to Bucket

Configure automatic cleanup of old state file versions:

```bash
# Create lifecycle policy JSON
cat > /tmp/terraform-state-lifecycle-policy.json <<'EOF'
[
  {
    "name": "delete-old-state-versions",
    "action": "DELETE",
    "is-enabled": true,
    "object-name-filter": {
      "inclusion-prefixes": ["deployment.tfstate"]
    },
    "time-amount": 90,
    "time-unit": "DAYS",
    "target": "previous-object-versions"
  },
  {
    "name": "retain-recent-versions",
    "action": "ARCHIVE",
    "is-enabled": false,
    "object-name-filter": {
      "inclusion-prefixes": ["deployment.tfstate"]
    },
    "time-amount": 30,
    "time-unit": "DAYS",
    "target": "previous-object-versions"
  }
]
EOF

# Apply lifecycle policy
oci os object-lifecycle-policy put \
  --bucket-name "$BUCKET_NAME" \
  --namespace-name "$NAMESPACE" \
  --items file:///tmp/terraform-state-lifecycle-policy.json

# Verify lifecycle policy
oci os object-lifecycle-policy get \
  --bucket-name "$BUCKET_NAME" \
  --namespace-name "$NAMESPACE"
```

#### Policy Explanation

**Rule 1: delete-old-state-versions (ENABLED)**
- **Action:** DELETE versions older than 90 days
- **Purpose:** Prevent unlimited storage growth
- **Impact:** Versions older than 90 days are permanently deleted
- **Rationale:** 90 days provides sufficient rollback history for operational needs

**Rule 2: retain-recent-versions (DISABLED - INTENTIONAL)**
- **Action:** ARCHIVE versions after 30 days (if enabled)
- **Status:** **DISABLED by design** - This is INTENTIONAL, not an oversight
- **Purpose:** Would move 30-90 day old versions to Archive storage tier

#### Why Rule 2 is Disabled (Important Design Decision)

The archive rule is **intentionally disabled** for sound operational and cost reasons:

**Cost-Benefit Analysis:**
- State file size: 231 KB (tiny)
- Current cost: ~$0.001/month (all versions in Standard tier)
- If archived: ~$0.00005/month (30-90 day versions in Archive)
- **Savings: Less than 1 penny per year** ❌

**Operational Impact:**
- Archive tier retrieval time: **4 HOURS** ⚠️
- Disaster recovery requires: **IMMEDIATE ACCESS** ✓
- State file rollback scenarios: **URGENT** (production incidents)
- Archive tier is for: **Cold storage**, not operational recovery

**Risk Assessment:**
```
Enabling Archive:
  Risk:   4-hour delay for emergency state recovery
  Reward: $0.00083/year savings (less than 1 penny)

Verdict: Risk vastly outweighs reward ❌
```

**Industry Best Practices:**
- AWS, Azure, GCP: Keep state versions in Standard/Hot tier
- Terraform state files are **operational data**, not **archival data**
- Archive tier is for: Compliance retention, large infrequently-accessed data
- NOT for: Small operational files requiring immediate disaster recovery

**When to Enable Archive Rule:**

Enable if:
- ✓ State file is large (>100 MB) with many versions
- ✓ Cost savings are significant (>$50/year)
- ✓ You have separate backup/recovery mechanisms
- ✓ You can tolerate 4-hour recovery time for old versions
- ✓ Compliance requires long-term retention (7+ years)

For typical deployments:
- ❌ State file is typically small (<1 MB)
- ❌ Cost savings negligible (<$1/year)
- ❌ Bucket versioning is PRIMARY disaster recovery mechanism
- ❌ Emergency recovery requires immediate access
- ❌ Most cases have no compliance requirement for extended retention

**Current Configuration (RECOMMENDED):**
- All versions (0-90 days): Standard tier (immediate access)
- Versions >90 days: Deleted (sufficient retention window)
- Cost: ~$0.001/month (~$0.01/year)
- Recovery: Instant access to any version within 90-day window
- Complexity: Low (no archive restore process needed)

---

### ✅ User/Group IAM Policies (Automated via Terraform)

> **IMPORTANT: These policies are managed by Terraform - NOT manual!**
>
> User and group access policies (for IAM Admins, Auditors, etc.) are automatically deployed
> by your Terraform code in the `oci-core-policies` module. You do **NOT** need to create
> these manually.
>
> The **only** policy that must be created manually is the Object Storage **SERVICE** policy
> above (Step 3), which allows the OCI service itself to execute lifecycle rules.

**What's Automated in Terraform:**
- ✅ IAM Admin group access to terraform-state bucket
- ✅ Auditor group read-only access to terraform-state bucket
- ✅ Dynamic group policies (if using CI/CD)

**What's Manual:**
- ❌ Object Storage service policy (Step 3 above) - Required for lifecycle rules, cannot be in Terraform bootstrap

---

## Terraform Backend Configuration

### Understanding the OCI Native Backend

Terraform 1.12.0+ includes native support for OCI Object Storage as a backend. This is **Oracle's recommended approach** with these key features:

- **Authentication:** Uses your existing `~/.oci/config` - no additional credentials needed
- **Setup Complexity:** Low - if OCI CLI works, backend works
- **State Locking:** Native support prevents concurrent modifications
- **Team Collaboration:** Each team member uses their own OCI credentials
- **Credential Management:** Managed through standard OCI CLI configuration
- **Oracle Support:** Official backend implementation, fully supported

> **Note:** If you're migrating from the S3-compatible backend approach, see the [migration section](#migrating-from-s3-compatible-backend) in the appendix.

### Step 5: Get User-Specific Values

You need two values to configure your backend.tf:

**1. Object Storage Namespace:**

```bash
# Get namespace (unique to your tenancy)
export NAMESPACE=$(oci os ns get --query "data" --raw-output)
echo "Your namespace: $NAMESPACE"

# Example output: frjpqj7r0mi3
```

**2. Region:**

```bash
# Get region from your terraform.tfvars
export REGION=$(grep 'region' deployment/terraform.tfvars | cut -d'"' -f2)
echo "Your region: $REGION"

# Example output: eu-frankfurt-1
```

**Save these values** - you'll need them in the next step.

### Step 6: Configure backend.tf

Update your `deployment/backend.tf` file with your specific values:

**Template (deployment/backend.tf):**

```hcl
# Terraform Backend Configuration - OCI Native Backend
#
# This uses OCI's native Terraform backend (recommended by Oracle)
# No AWS credentials needed - uses your OCI CLI configuration
#
# Requirements:
# - Terraform >= 1.12.0
# - OCI CLI configured (~/.oci/config)
#
# Team Collaboration:
# - State stored in OCI Object Storage
# - Automatic state locking
# - All team members use their own OCI credentials
# - Access controlled via IAM policies
#
# Authentication:
# - Uses OCI CLI config by default (~/.oci/config)
# - Or uses environment variables (OCI_TENANCY_OCID, etc.)
#
# State Location:
# - Bucket: terraform-state
# - Object: deployment.tfstate

terraform {
  required_version = ">= 1.12.0"

  backend "oci" {
    bucket    = "terraform-state"
    key       = "deployment.tfstate"
    namespace = "<YOUR_NAMESPACE_HERE>"      # Replace with your namespace from Step 5
    region    = "<YOUR_REGION_HERE>"         # Replace with your region from Step 5

    # Authentication via OCI CLI config
    # No additional credentials needed!
    # Team members use their own ~/.oci/config
  }
}
```

**How to Update:**

**Option 1: Manual Edit**
```bash
# Edit the file
nano deployment/backend.tf  # or vim, code, etc.

# Replace the placeholders:
# - <YOUR_NAMESPACE_HERE> → Your actual namespace (e.g., frjpqj7r0mi3)
# - <YOUR_REGION_HERE> → Your actual region (e.g., eu-frankfurt-1)
```

**Option 2: Automated with sed**
```bash
# Use the values from Step 5
NAMESPACE=$(oci os ns get --query "data" --raw-output)
REGION=$(grep 'region' deployment/terraform.tfvars | cut -d'"' -f2)

# Create backend.tf from template
cat > deployment/backend.tf <<EOF
# Terraform Backend Configuration - OCI Native Backend
#
# This uses OCI's native Terraform backend (recommended by Oracle)
# No AWS credentials needed - uses your OCI CLI configuration
#
# Requirements:
# - Terraform >= 1.12.0
# - OCI CLI configured (~/.oci/config)
#
# Team Collaboration:
# - State stored in OCI Object Storage
# - Automatic state locking
# - All team members use their own OCI credentials
# - Access controlled via IAM policies
#
# Authentication:
# - Uses OCI CLI config by default (~/.oci/config)
# - Or uses environment variables (OCI_TENANCY_OCID, etc.)
#
# State Location:
# - Bucket: terraform-state
# - Object: deployment.tfstate

terraform {
  required_version = ">= 1.12.0"

  backend "oci" {
    bucket    = "terraform-state"
    key       = "deployment.tfstate"
    namespace = "$NAMESPACE"
    region    = "$REGION"

    # Authentication via OCI CLI config
    # No additional credentials needed!
    # Team members use their own ~/.oci/config
  }
}
EOF

echo "✅ backend.tf configured with:"
echo "   Namespace: $NAMESPACE"
echo "   Region: $REGION"
```

**Verify Configuration:**

```bash
# Check the file was created correctly
cat deployment/backend.tf | grep -E "namespace|region"

# Expected output should show your actual values (NOT placeholders):
#     namespace = "frjpqj7r0mi3"
#     region    = "eu-frankfurt-1"
```

**Example Complete backend.tf:**

```hcl
terraform {
  required_version = ">= 1.12.0"

  backend "oci" {
    bucket    = "terraform-state"
    key       = "deployment.tfstate"
    namespace = "frjpqj7r0mi3"        # Your actual namespace
    region    = "eu-frankfurt-1"       # Your actual region

    # Authentication via OCI CLI config
    # No additional credentials needed!
  }
}
```

---

## Deployment Procedure

### Step 7: Initialize Backend (First Time)

> **📝 NEW DEPLOYMENT NOTE**
>
> For brand new deployments, there is NO state to migrate. You'll just run `terraform init` (not `terraform init -migrate-state`).
> This is much simpler!

**Authentication:**

The OCI native backend uses your existing OCI CLI configuration. Ensure it's working:

```bash
# Verify OCI CLI authentication
oci os ns get

# If this fails, reconfigure:
# oci setup config
```

**Initialize Terraform:**

```bash
# Navigate to deployment directory
cd deployment

# Initialize backend (creates remote state)
terraform init

# Expected output:
# Initializing the backend...
# Successfully configured the backend "oci"!
#
# Terraform has been successfully initialized!
```

**What Happens:**
1. Terraform reads `backend.oci` configuration from backend.tf
2. Connects to OCI Object Storage using your ~/.oci/config credentials
3. Creates `deployment.tfstate` in the `terraform-state` bucket
4. Sets up state locking infrastructure
5. Downloads provider plugins

**Note:** For new deployments, there is NO `-migrate-state` flag needed. Terraform will create the remote state file automatically on first `terraform apply`.

### Step 8: Deploy Infrastructure

```bash
# Navigate to deployment directory (if not already there)
cd deployment

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply

# This will create:
# - shared-services compartment
# - SaaS-Root and sub-compartments
# - IaaS-Root and sub-compartments
# - 43 IAM groups
# - All policies and security resources
# - State automatically saved to remote bucket after each operation
```

**State Management During Apply:**
- Terraform automatically acquires state lock before operations
- State is updated in OCI Object Storage after each change
- Lock is released when operation completes
- All changes logged via OCI Audit service

### Step 9: Verify Remote State

```bash
# Navigate to deployment directory
cd deployment

# Verify state is now remote
terraform state list | head -20

# Check local state file is now a pointer (should be very small or not exist)
ls -lh terraform.tfstate 2>/dev/null || echo "No local state file (expected)"

# Verify remote state exists in bucket
oci os object list \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)"

# Expected output: deployment.tfstate object exists

# Download and inspect remote state
oci os object get \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --file "/tmp/remote-state-verify.json"

# Check state file size
ls -lh /tmp/remote-state-verify.json

# View state structure
jq '.version, .terraform_version, (.resources | length)' /tmp/remote-state-verify.json
```

---

## Daily Operations

### Standard Workflow

With the OCI native backend, your workflow is **extremely simple** - no credential sourcing needed!

```bash
# 1. Navigate to deployment directory
cd deployment

# 2. Run Terraform commands (uses ~/.oci/config automatically)
terraform plan
terraform apply
terraform destroy  # (will NOT destroy state bucket - it's safe!)

# That's it! No credential sourcing, no environment variables needed.
```

**How Authentication Works:**

Terraform uses your existing OCI CLI configuration:
- Reads `~/.oci/config` for authentication
- Uses the `[DEFAULT]` profile by default
- Or set `OCI_CLI_PROFILE` environment variable for different profile
- Each team member uses their own credentials
- Access controlled via IAM policies

**Using Different OCI Profiles:**

```bash
# Use a specific OCI CLI profile
export OCI_CLI_PROFILE=production
terraform plan

# Or specify in backend configuration (backend.tf):
# backend "oci" {
#   ...
#   profile = "production"
# }
```

### Testing State Operations

```bash
# Navigate to deployment directory
cd deployment

# Test plan operation (reads state)
terraform plan

# Expected: Should complete successfully, show no changes

# Test state pull
terraform state pull > /tmp/current-state.json
cat /tmp/current-state.json | jq '.resources | length'
# Should show your resource count

# Test refresh
terraform refresh

# Verify remote state was updated (check timestamp)
oci os object head \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --query "last-modified"
```

## What This Protects

The state bucket (`terraform-state`) is **foundational infrastructure**:
- Created manually, NOT managed by Terraform
- Running `terraform destroy` will NOT delete the state bucket
- State bucket will survive even if all Terraform-managed resources are destroyed
- See architecture diagram for Tier 0 vs Tier 1 separation

---

## Testing and Validation

### Test 1: State Read

```bash
cd deployment

# Pull and verify state
terraform state pull | jq '.version, .terraform_version, (.resources | length)'

# Expected output: Version, Terraform version, and resource count
```

### Test 2: State Write

```bash
cd deployment

# Trigger state update
terraform refresh

# Verify state was updated remotely (check timestamp)
oci os object head \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --query '"last-modified"'
```

### Test 3: Concurrent Access (State Locking)

Open two terminal windows:

```bash
# Terminal 1
cd deployment
terraform plan -lock-timeout=60s

# While Terminal 1 is running, in Terminal 2:
cd deployment
terraform plan -lock-timeout=10s

# Expected: Terminal 2 shows lock error
# This confirms state locking works correctly
```

### Test 4: Versioning

```bash
# Make a change
terraform refresh

# Check versions
oci os object list-object-versions \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --prefix "deployment.tfstate" \
  | jq '.data | length'

# Should show multiple versions
```

### Test 5: Recovery

```bash
# List versions
VERSIONS=$(oci os object list-object-versions \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --query 'data[*]."version-id"' \
  --raw-output)

# Get previous version
PREV_VERSION=$(echo "$VERSIONS" | sed -n '2p')

# Download it
oci os object get \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --version-id "$PREV_VERSION" \
  --file "/tmp/previous-state.json"

# Verify
jq '.serial' /tmp/previous-state.json
```

### Test 6: Team Collaboration

Verify different team members can access state using their own credentials:

```bash
# Team Member A (using their ~/.oci/config)
cd deployment
terraform plan  # Should work

# Team Member B (using their ~/.oci/config)
cd deployment
terraform plan  # Should also work

# Both access the same state, but with their own credentials
# Access is controlled via IAM policies (IAM_OCI_SECUREROLE_IAMAdmins group)
```

---

## Troubleshooting

### Problem: `Error: Unsupported backend type "oci"`

**Cause:** Terraform version is too old (< 1.12.0)

**Solution:**
```bash
# Check Terraform version
terraform version

# If < 1.12.0, upgrade Terraform
# Download from: https://www.terraform.io/downloads
```

### Problem: `Error: error connecting to backend`

**Cause:** OCI CLI not configured or credentials invalid

**Solution:**
```bash
# Verify OCI CLI is working
oci os ns get

# If fails, reconfigure OCI CLI
oci setup config

# Test again
oci os ns get
```

### Problem: `Error: Failed to get existing workspaces`

**Cause:** Workspaces are supported but require specific configuration

**Solution:** For multiple environments, use:
- Separate state keys (e.g., `dev.tfstate`, `prod.tfstate`)
- Separate buckets (e.g., `terraform-state-dev`, `terraform-state-prod`)
- Or Terraform workspaces with backend configuration

### Problem: `Error: bucket does not exist`

**Cause:** Bucket not created or wrong namespace/region

**Solution:**
```bash
# Verify bucket exists
NAMESPACE=$(oci os ns get --query "data" --raw-output)
oci os bucket get --bucket-name terraform-state --namespace-name "$NAMESPACE"

# Verify backend.tf has correct namespace and region
cat deployment/backend.tf | grep -E "namespace|region"
```

### Problem: `Error: 401 Not Authenticated`

**Cause:** OCI credentials expired or invalid

**Solution:**
```bash
# Check OCI CLI configuration
cat ~/.oci/config

# Verify API key exists and is valid
ls -la ~/.oci/*.pem

# Test authentication
oci iam user get --user-id "$(grep user_ocid deployment/terraform.tfvars | cut -d'"' -f2)"

# If needed, generate new API key in OCI Console and update ~/.oci/config
```

### Problem: `Error: Insufficient permissions`

**Cause:** User doesn't have required IAM permissions

**Solution:**

Required permissions for state bucket access:
```
Allow group IAM_OCI_SECUREROLE_IAMAdmins to manage objects in tenancy where target.bucket.name='terraform-state'
Allow group IAM_OCI_SECUREROLE_IAMAdmins to read buckets in tenancy where target.bucket.name='terraform-state'
```

These policies should be automatically created by your Terraform code in `oci-core-policies` module.

Verify user is in correct group:
```bash
# List your groups
oci iam user list-groups --user-id "$(grep user_ocid deployment/terraform.tfvars | cut -d'"' -f2)"
```

### Problem: State lock won't release

**Cause:** Previous operation terminated unexpectedly

**Solution:**
```bash
# Check for lock file
oci os object list \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  | grep lock

# Force unlock (use with caution!)
terraform force-unlock <lock-id>

# Lock ID shown in error message
```

---

## Security and Compliance

### CIS Benchmark Alignment

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| **1.14** | Storage service logging | Bucket audit logging enabled | ✓ |
| **2.1** | No resources in root | Bootstrap exception: Bucket at tenancy level | ⚠️ |
| **3.1** | 365-day audit retention | OCI default | ✓ |
| **4.1** | Use compartments | Proper compartmentalization | ✓ |
| **4.2** | No root compartment use | Bootstrap exception: State bucket at tenancy level | ⚠️ |

### Encryption

**At Rest:**
- Oracle-managed AES-256 encryption (automatic)
- All objects encrypted by default
- Optional: Customer-managed keys via OCI Vault

**In Transit:**
- HTTPS/TLS 1.2+ for all API calls
- OCI native backend uses HTTPS
- No unencrypted access possible

### Access Control

**Current Access:**
- IAM_OCI_SECUREROLE_IAMAdmins: Read/write
- CIS-Auditors: Read-only
- All access logged via OCI Audit

**Best Practices:**
- Review access quarterly
- Rotate API keys every 90 days (per CIS 1.8-1.11)
- Monitor audit logs monthly
- Document all access changes
- Each team member uses their own OCI credentials (no shared credentials)

### Audit Logging

All access to the terraform-state bucket is automatically logged:

```bash
# Query audit logs for state bucket access
# (Requires OCI CLI and appropriate permissions)

# Get audit events for past 7 days
START_TIME=$(date -u -d '7 days ago' '+%Y-%m-%dT%H:%M:%SZ')
END_TIME=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

oci audit event list \
  --compartment-id "$TENANCY_OCID" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --query "data[?contains(\"data\".\"resource-name\", 'terraform-state')].{
    time:\"event-time\",
    user:\"data\".\"identity\".\"principal-name\",
    action:\"data\".\"event-name\",
    resource:\"data\".\"resource-name\"
  }"
```

---

## References

### OCI Documentation

- [Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Object Storage Versioning](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingversioning.htm)
- [IAM Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm)
- [CIS OCI Benchmark](https://www.cisecurity.org/benchmark/oracle_cloud)
- [OCI CLI Configuration](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm)

### Terraform Documentation

- [OCI Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/oci)
- [Backend Configuration](https://www.terraform.io/docs/language/settings/backends/index.html)
- [State Locking](https://www.terraform.io/docs/language/state/locking.html)
- [State Management](https://www.terraform.io/docs/cli/state/index.html)

### Industry Best Practices

- [HashiCorp: Terraform Recommended Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Gruntwork: Terraform State](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa)
- [AWS: Bootstrap Pattern](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/bootstrap-terraform-automation.html)

---

## Appendix: Quick Reference

### Essential Commands

```bash
# Backend initialization
terraform init                    # First-time setup
terraform init -migrate-state     # Migrate from local state (if needed)
terraform init -reconfigure       # Reconfigure backend

# State operations
terraform state list              # List all resources
terraform state show <resource>   # Show specific resource
terraform state pull              # Download state
terraform state push <file>       # Upload state (use with extreme caution!)
terraform force-unlock <id>       # Force unlock (emergency only)

# Bucket operations
NAMESPACE=$(oci os ns get --query "data" --raw-output)
oci os object list --bucket-name terraform-state --namespace-name "$NAMESPACE"
oci os object get --bucket-name terraform-state --name deployment.tfstate --file state.json --namespace-name "$NAMESPACE"
oci os object list-object-versions --bucket-name terraform-state --name deployment.tfstate --namespace-name "$NAMESPACE"

# Get user-specific values for backend.tf
oci os ns get --query "data" --raw-output  # Get namespace
grep 'region' deployment/terraform.tfvars | cut -d'"' -f2  # Get region
```

### Configuration Summary

**Backend (deployment/backend.tf):**

```hcl
terraform {
  required_version = ">= 1.12.0"

  backend "oci" {
    bucket    = "terraform-state"
    key       = "deployment.tfstate"
    namespace = "<YOUR_NAMESPACE>"     # From: oci os ns get
    region    = "<YOUR_REGION>"        # From: terraform.tfvars

    # Uses ~/.oci/config for authentication automatically
    # No additional configuration needed!
  }
}
```

**Authentication:**
- Uses `~/.oci/config` by default
- Or set `OCI_CLI_PROFILE` environment variable
- No separate credentials file needed
- Each team member uses their own OCI credentials

### Migrating from S3-Compatible Backend

If you previously used the S3-compatible backend and want to migrate:

```bash
# 1. Update backend.tf (remove all S3/AWS references)
# Replace:
#   backend "s3" {
#     bucket   = "terraform-state"
#     key      = "deployment.tfstate"
#     region   = "us-ashburn-1"
#     endpoint = "https://....compat.objectstorage..."
#     skip_region_validation = true
#     skip_credentials_validation = true
#     skip_metadata_api_check = true
#     force_path_style = true
#   }
#
# With:
#   backend "oci" {
#     bucket    = "terraform-state"
#     key       = "deployment.tfstate"
#     namespace = "<your-namespace>"
#     region    = "<your-region>"
#   }

# 2. Remove credentials file (no longer needed)
# rm ~/.oci/terraform-backend-credentials

# 3. Reinitialize backend
cd deployment
terraform init -reconfigure

# Terraform will migrate state automatically
# Expected output: "Successfully configured the backend "oci"!"

# 4. Verify state access
terraform state list
```

### Team Onboarding Checklist

When adding new team members:

- [ ] Ensure new member has OCI CLI installed and configured
- [ ] Verify their ~/.oci/config is working: `oci os ns get`
- [ ] Add user to IAM_OCI_SECUREROLE_IAMAdmins group (or appropriate group with state bucket access)
- [ ] Verify user can access state: `cd deployment && terraform plan`
- [ ] Document which OCI profile they should use (if not [DEFAULT])
- [ ] No credential sharing needed - they use their own OCI credentials!

---

**End of Guide**

For questions or issues, consult the troubleshooting section or refer to the OCI and Terraform documentation links in the References section.
