# Terraform Remote State Setup Guide
## OCI Object Storage Backend Configuration

**Last Updated:** 2025-10-30
**Author:** Panagiotis 'Pano' Georgiadis
**Environment:** OCI-Hanover Production Infrastructure

---

## Executive Summary

This guide provides comprehensive instructions for migrating Terraform state management from local storage to OCI Object Storage as a remote backend, **using the correct architectural pattern to avoid the bootstrap problem**.

**Target State:**
- **New deployment** - No existing local state file
- Remote state storage in OCI Object Storage at tenancy level
- Clean start with remote backend from day one
- Terraform version: 1.13.3+

**Benefits of Remote State:**
- Centralized state storage with team collaboration support
- Automatic state locking to prevent concurrent modifications
- State file versioning and disaster recovery
- Enhanced security with OCI IAM and encryption
- Audit logging of all state access
- CIS compliance alignment (encryption, logging, access control)

**Recommended Solution:** **Manual Bucket Creation (Bootstrap Separation Pattern)**

**Implementation Timeline:** 1-2 hours
**Risk Level:** Low (with proper backup and rollback plan)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Decision: Bootstrap Pattern Selection](#architecture-decision-bootstrap-pattern-selection)
3. [Recommended Solution: Manual Bootstrap](#recommended-solution-manual-bootstrap)
4. [Alternative Solutions](#alternative-solutions)
5. [OCI Infrastructure Setup](#oci-infrastructure-setup)
6. [IAM Policies Configuration](#iam-policies-configuration)
7. [Terraform Backend Configuration](#terraform-backend-configuration)
8. [State Migration Procedure](#state-migration-procedure)
9. [Testing and Validation](#testing-and-validation)
10. [Protection Strategies](#protection-strategies)
11. [Operations and Maintenance](#operations-and-maintenance)
12. [Troubleshooting Guide](#troubleshooting-guide)
13. [Rollback Procedure](#rollback-procedure)
14. [References](#references)

---

## Prerequisites

### Required Access

- [ ] OCI tenancy administrator access or equivalent permissions
- [ ] Ability to create Object Storage buckets
- [ ] **Ability to create IAM policies at tenancy level (CRITICAL for service policy)**
- [ ] Access to shared-services compartment (or root compartment)
- [ ] Current working Terraform deployment (able to run `terraform plan`)

### Required Tools

- [ ] Terraform >= 1.3 (currently using 1.13.3 ✓)
- [ ] OCI CLI configured with valid credentials
- [ ] API key or instance principal authentication configured
- [ ] Backup of current state file

### Environment Variables

Ensure these are available (typically in `terraform.tfvars`):

```hcl
tenancy_ocid         = "ocid1.tenancy.oc1..xxxxx"
user_ocid            = "ocid1.user.oc1..xxxxx"
fingerprint          = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path     = "/path/to/oci_api_key.pem"
private_key_password = ""  # if key is encrypted
region               = "us-ashburn-1"  # or your region
```

### Pre-Migration Checklist

- [ ] Backup current state file: `cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d)`
- [ ] Verify no pending changes: `terraform plan` shows no changes
- [ ] Document current Terraform workspace: `terraform workspace show`
- [ ] Test OCI authentication: `oci os ns get`
- [ ] Verify no locks exist: Check for `.terraform.tfstate.lock.info`
- [ ] Commit current code to git: `git status` clean
- [ ] Notify team members of maintenance window

---

## Architecture Decision: Bootstrap Pattern Selection

### The Three Approaches

There are three industry-standard approaches to solving the Terraform state bootstrap problem:

| Approach | State Bucket Managed By | State for Bucket Stored In | Destroy Risk | Complexity |
|----------|------------------------|----------------------------|--------------|------------|
| **A: Manual Bootstrap** | Manual creation (CLI/Console) | N/A (not managed by Terraform) | None | Low |
| **B: Separate Bootstrap Project** | Dedicated Terraform project | Local or separate remote | Low | Medium |
| **C: Lifecycle Protection** | Main Terraform project | Same bucket (self-referential) | Medium | High |

### Decision Matrix

Use this matrix to select the right approach for your situation:

```
┌─────────────────────────────────────────────────────────────────┐
│                    DECISION TREE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Q1: Is this a single-person project or small team?            │
│      └─ YES → Use Approach A (Manual Bootstrap)                │
│      └─ NO  → Continue to Q2                                   │
│                                                                 │
│  Q2: Do you need state infrastructure as code?                 │
│      └─ NO  → Use Approach A (Manual Bootstrap)                │
│      └─ YES → Continue to Q3                                   │
│                                                                 │
│  Q3: Do you have multiple environments (dev/stage/prod)?       │
│      └─ YES → Use Approach B (Separate Bootstrap)              │
│      └─ NO  → Continue to Q4                                   │
│                                                                 │
│  Q4: Are you comfortable with self-referential state?          │
│      └─ NO  → Use Approach B (Separate Bootstrap)              │
│      └─ YES → Use Approach C (Lifecycle Protection)            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Recommendation for OCI-Hanover

**Recommended: Approach A (Manual Bootstrap)**

**Rationale:**
- Single production environment
- Small team (likely 1-3 administrators)
- Critical infrastructure (90+ resources) - minimize complexity
- State bucket is long-lived infrastructure (rarely changes)
- Separates "foundational" infrastructure from "managed" infrastructure
- Eliminates destroy risk completely
- Simplest to understand and maintain

**When to reconsider:**
- Scaling to multiple environments (then use Approach B)
- Organizational requirement for 100% IaC (then use Approach B)
- Large team with strict change management (then use Approach B)

---

## Recommended Solution: Manual Bootstrap

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
```

### Benefits of Manual Bootstrap

**Advantages:**
1. **No Destroy Risk** - Bucket cannot be accidentally destroyed by `terraform destroy`
2. **Clear Separation** - Foundational vs managed infrastructure is explicit
3. **Simplicity** - Easy to understand and explain to team
4. **Industry Standard** - Used by AWS (S3 + DynamoDB), Azure (Storage Account), GCP (GCS)
5. **Auditability** - Clear separation between "bootstrap" and "operational" changes
6. **Recovery** - If Terraform state is lost, foundational infrastructure remains intact

**Disadvantages:**
1. **Not Pure IaC** - State bucket not in Terraform (acceptable trade-off)
2. **Manual Step** - One-time manual creation required
3. **Documentation** - Must document manual bucket creation (this guide does that)

**Trade-off Analysis:**

| Factor | Weight | Manual Bootstrap | Terraform-Managed | Winner |
|--------|--------|------------------|-------------------|---------|
| Safety from accidental destroy | Critical | Excellent | Poor | Manual |
| Infrastructure as Code purity | Medium | Poor | Excellent | Terraform |
| Operational simplicity | High | Excellent | Poor | Manual |
| Team understanding | High | Excellent | Poor | Manual |
| Disaster recovery | Critical | Excellent | Poor | Manual |

**Conclusion:** Manual bootstrap wins on critical factors (safety, simplicity, disaster recovery).

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
export TENANCY_OCID=$(grep 'tenancy_ocid' /home/panog/OCI-Hanover/deployment/terraform.tfvars | cut -d'"' -f2)

# Verify
echo "Tenancy OCID: $TENANCY_OCID"

# Alternative: Use OCI CLI
# export TENANCY_OCID=$(oci iam compartment list --compartment-id-in-subtree false --query 'data[0].\"compartment-id\"' --raw-output)
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

# Save this value - you'll need it multiple times
```

**Set Required Variables:**

```bash
# Set variables for bucket creation
export TENANCY_OCID=$(grep 'tenancy_ocid' /home/panog/OCI-Hanover/deployment/terraform.tfvars | cut -d'"' -f2)
export REGION=$(grep 'region' /home/panog/OCI-Hanover/deployment/terraform.tfvars | cut -d'"' -f2)
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

### Step 3: Configure Bucket Lifecycle Policy

To manage state file versions and prevent unlimited storage growth:

```bash
# Get OCI Region for service policy
REGION=$(oci iam region-subscription list \
  --query 'data[?"is-home-region"==`true`]."region-name" | [0]' \
  --raw-output)

# Create service policy
oci iam policy create \
  --compartment-id "$TENANCY_OCID" \
  --name "objectstorage-lifecycle-service-policy" \
  --description "Allow Object Storage service to manage lifecycle policies on terraform-state bucket" \
  --statements '[
    "Allow service objectstorage-${REGION} to manage object-family in tenancy where target.bucket.name='"'"'terraform-state'"'"'"
  ]' \
  --freeform-tags '{
    "Purpose":"Object Storage Lifecycle Management",
    "ManagedBy":"Manual"
  }'

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

For OCI-Hanover (current state):
- ❌ State file is tiny (231 KB)
- ❌ Cost savings negligible (<$1/year)
- ❌ Bucket versioning is PRIMARY disaster recovery mechanism
- ❌ Emergency recovery requires immediate access
- ❌ No compliance requirement for extended retention

**Current Configuration (RECOMMENDED):**
- All versions (0-90 days): Standard tier (immediate access)
- Versions >90 days: Deleted (sufficient retention window)
- Cost: ~$0.001/month (~$0.01/year)
- Recovery: Instant access to any version within 90-day window
- Complexity: Low (no archive restore process needed)

**Alternative: Remove Rule 2 Entirely**

Since Rule 2 is disabled, you could optionally remove it from the policy JSON entirely:

```json
{
  "items": [
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
    }
  ]
}
```

However, keeping the disabled rule documents that archiving was **considered and intentionally rejected**, which helps future maintainers understand the decision rationale.



### Verify Policy Access

```bash
# Test bucket access as current user
oci os object list \
  --bucket-name "terraform-state" \
  --namespace-name "$NAMESPACE"

# Should return empty list (bucket exists but has no objects yet)
# If you get permission denied, check group membership and policies
```

---

## Terraform Backend Configuration

### Step 6: Choose Backend Type

OCI Object Storage can be used as a Terraform backend using the **HTTP backend** or **S3-compatible backend**. We recommend the S3-compatible backend for better state locking support.

#### Understanding Backend Options

| Backend Type | Protocol | State Locking | Complexity | Recommendation |
|--------------|----------|---------------|------------|----------------|
| HTTP | REST API | Limited | Medium | Good for simple setups |
| S3-Compatible | S3 API | Native | Low | **Recommended** |

### Step 7: Create Customer Secret Keys (for S3-Compatible Backend)

```bash
# Grab your User OCID
USER_OCID=$(oci iam user list \
  --compartment-id "$TENANCY_OCID" \
  --query "data[?name=='[Your Username]'].id | [0]" \
  --raw-output)

# Create S3-compatible access keys for your OCI user
oci iam customer-secret-key create \
  --user-id "$USER_OCID" \
  --display-name "Terraform State Backend Access"

# Output will show:
# {
#   "data": {
#     "id": "ocid1.credential.oc1..xxx",
#     "key": "abc123xyz...",              # This is the Access Key
#     "display-name": "Terraform State Backend Access",
#     "time-created": "2025-10-30...",
#     "user-id": "ocid1.user.oc1..xxx"
#   }
# }

# IMPORTANT: Copy the "key" value - this is shown only once!
# Also copy the "id" - you'll need this to retrieve the secret key

# Get the secret key (shown only at creation)
# Store these securely - you'll need them for backend configuration
```

**CRITICAL: Store Credentials Securely**

```bash
# Create secure credentials file (never commit to git!)
cat > .oci/terraform-backend-credentials <<'EOF'
# OCI S3-Compatible Credentials for Terraform Backend
# Created: 2025-10-30
# Purpose: Remote state access

export AWS_ACCESS_KEY_ID="<customer-secret-key-id>"
export AWS_SECRET_ACCESS_KEY="<customer-secret-key-value>"
EOF

# Secure the file
chmod 600 .oci/terraform-backend-credentials

# Add to .gitignore
echo ".oci/terraform-backend-credentials" >> /OCI-Hanover/.gitignore
```

### Step 8: Configure Backend

**Replace placeholders: in OCI-Hanover/deployment/backend.tf**
- `<YOUR_NAMESPACE>`: Your Object Storage namespace (from `oci os ns get`)
- `<YOUR_REGION>`: Your OCI region

**Run backend configuration helper script:**

```bash
# Run helper script for loading backend credentials
bash deployment/init-backend.sh
```

---

## State Migration Procedure

### Step 9: Update backend.tf with Correct Values

> **📝 NEW DEPLOYMENT NOTE**
>
> For brand new deployments, there is NO state to migrate. You'll just run `terraform init` (not `terraform init -migrate-state`).
> This is much simpler!

```bash
cd /OCI-Hanover/deployment

# Get namespace
NAMESPACE=$(oci os ns get --query "data" --raw-output)

# Get region from terraform.tfvars
REGION=$(grep 'region =' terraform.tfvars | cut -d'"' -f2)

# Display values to update in backend.tf
echo "Update backend.tf with these values:"
echo "  endpoint = \"https://${NAMESPACE}.compat.objectstorage.${REGION}.oraclecloud.com\""
echo "  region   = \"${REGION}\""
```

Manually edit `backend.tf` to replace placeholders with actual values.

### Step 10: Initialize Backend (New Deployment - No Migration!)

```bash
cd /home/panog/OCI-Hanover/deployment

# Load backend credentials
source ~/.oci/terraform-backend-credentials

# Verify credentials loaded
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "ERROR: Credentials not loaded"
    exit 1
fi

# Initialize backend (creates remote state)
terraform init

# Expected output:
# Successfully configured the backend "s3"!
# Terraform has been successfully initialized!
```

**Note:** For new deployments, there is NO `-migrate-state` flag needed. Terraform will create the remote state file automatically.

### Step 11: Deploy Infrastructure

```bash
cd /home/panog/OCI-Hanover/deployment

# Ensure credentials still loaded
source ~/.oci/terraform-backend-credentials

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
# - State automatically saved to remote bucket
```

### Step 12: Verify Remote State

```bash
cd /home/panog/OCI-Hanover/deployment

# Verify state is now remote
terraform state list | head -20

# Check local state file is now a pointer
cat terraform.tfstate
# Should be minimal JSON with backend information

# Verify remote state exists in bucket
oci os object list \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)"

# Expected output: deployment.tfstate object exists

# Download and verify remote state
oci os object get \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --file "/tmp/remote-state-verify.json"

# Compare with backup (should be nearly identical)
diff -u terraform.tfstate.pre-migration /tmp/remote-state-verify.json | head -50

# Check state file size
ls -lh /tmp/remote-state-verify.json
# Should be ~231 KB
```

### Step 14: Test Remote State Operations

```bash
cd /home/panog/OCI-Hanover/deployment

# Ensure credentials loaded
source ~/.oci/terraform-backend-credentials

# Test plan operation (reads state)
terraform plan

# Expected: Should complete successfully, show no changes

# Test state pull
terraform state pull > /tmp/current-state.json
cat /tmp/current-state.json | jq '.resources | length'
# Should show your resource count (90+)

# Test refresh
terraform refresh

# Verify remote state was updated
oci os object head \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --query "etag"
```


## Standard Workflow

```bash
# 1. Navigate to deployment directory
cd /home/panog/OCI-Hanover/deployment

# 2. Load credentials
source ~/.oci/terraform-backend-credentials

# 3. Run Terraform commands
terraform plan
terraform apply
terraform destroy  # (will NOT destroy state bucket - it's safe!)
```

## What This Protects

The state bucket (`terraform-state`) is **foundational infrastructure**:
- Created manually, NOT managed by Terraform
- Running `terraform destroy` will NOT delete the state bucket
- State bucket will survive even if all Terraform-managed resources are destroyed
- See FOUNDATIONAL_INFRASTRUCTURE.md for details

## Troubleshooting

**Problem:** `Error: Unsupported backend type "s3"`

**Solution:** Credentials not loaded. Run:
```bash
source ~/.oci/terraform-backend-credentials
```

**Problem:** `Error: error connecting to backend`

**Solution:** Verify bucket exists and credentials are valid:
```bash
oci os bucket get --bucket-name terraform-state


### Step 16: Clean Up and Commit

```bash
cd /home/panog/OCI-Hanover/deployment

# Keep backups, but remove old .backup files (optional)
# rm terraform.tfstate.backup.* # Only after confirming migration success

# Add backend configuration to git
git add backend.tf
git add README-BACKEND.md
git add init-backend.sh

# Commit changes
git commit -m "Configure OCI Object Storage remote backend using manual bootstrap pattern

- Add S3-compatible backend configuration
- Migrate state from local to remote storage
- State bucket created manually (foundational infrastructure)
- Implements bootstrap separation pattern for safety
- State cannot be destroyed by terraform destroy
- Added helper scripts for credential management
- Documented workflow in README-BACKEND.md

Architecture:
- Tier 0 (Foundational): terraform-state bucket (manual, protected)
- Tier 1 (Managed): All infrastructure resources (Terraform-managed)

Benefits:
- No circular dependency
- No destroy risk
- Clear separation of concerns
- Industry-standard bootstrap pattern"

# Push to remote
git push origin main
```

---

## Testing and Validation

### Test 1: State Read

```bash
cd /home/panog/OCI-Hanover/deployment
source ~/.oci/terraform-backend-credentials

# Pull and verify state
terraform state pull | jq '.version, .terraform_version, (.resources | length)'

# Expected output:
# 4
# "1.13.3"
# 90+
```

### Test 2: State Write

```bash
# Add a tag to trigger minor change
terraform refresh

# Verify state was updated remotely
oci os object head \
  --bucket-name "terraform-state" \
  --namespace-name "$(oci os ns get --query 'data' --raw-output)" \
  --name "deployment.tfstate" \
  --query '"last-modified"'
```

### Test 3: Concurrent Access

Open two terminal windows:

```bash
# Terminal 1
cd /home/panog/OCI-Hanover/deployment
source ~/.oci/terraform-backend-credentials
terraform plan -lock-timeout=60s

# While running, in Terminal 2:
cd /home/panog/OCI-Hanover/deployment
source ~/.oci/terraform-backend-credentials
terraform plan -lock-timeout=10s

# Expected: Terminal 2 shows lock error
# This confirms locking works
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
- S3-compatible API uses HTTPS
- No unencrypted access possible

### Access Control

**Current Access:**
- IAM_OCI_SECUREROLE_IAMAdmins: Read/write
- CIS-Auditors: Read-only
- All access logged via OCI Audit

**Best Practices:**
- Review access quarterly
- Rotate Customer Secret Keys every 90 days
- Monitor audit logs monthly
- Document all access changes

---

## References

### OCI Documentation

- [Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Object Storage Versioning](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingversioning.htm)
- [Customer Secret Keys](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#Working2)
- [IAM Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm)
- [CIS OCI Benchmark](https://www.cisecurity.org/benchmark/oracle_cloud)

### Terraform Documentation

- [Backend Configuration](https://www.terraform.io/docs/language/settings/backends/index.html)
- [S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
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
# Load credentials (required before any terraform command)
source ~/.oci/terraform-backend-credentials

# Backend initialization
terraform init                    # First-time setup
terraform init -migrate-state     # Migrate from local state
terraform init -reconfigure       # Reconfigure backend

# State operations
terraform state list              # List all resources
terraform state show <resource>   # Show specific resource
terraform state pull              # Download state
terraform state push <file>       # Upload state
terraform force-unlock <id>       # Force unlock (emergency)

# Bucket operations
NAMESPACE=$(oci os ns get --query "data" --raw-output)
oci os object list --bucket-name terraform-state --namespace-name "$NAMESPACE"
oci os object get --bucket-name terraform-state --name deployment.tfstate --file state.json
oci os object list-object-versions --bucket-name terraform-state --name deployment.tfstate
```

### Configuration Summary

**Backend (backend.tf):**
```hcl
terraform {
  backend "s3" {
    bucket   = "terraform-state"
    key      = "deployment.tfstate"
    region   = "us-ashburn-1"
    endpoint = "https://<namespace>.compat.objectstorage.us-ashburn-1.oraclecloud.com"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

**Credentials (~/.oci/terraform-backend-credentials):**
```bash
export AWS_ACCESS_KEY_ID="<customer-secret-key-id>"
export AWS_SECRET_ACCESS_KEY="<customer-secret-key-value>"
```

---
