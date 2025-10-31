# Foundational Infrastructure Documentation

## Purpose

This document records Tier 0 (Foundational) infrastructure that is NOT managed by Terraform.
This infrastructure must exist before Terraform can run and is protected from Terraform lifecycle.

## Terraform Remote State Bucket

**Created:** 2025-10-30

**Created By:** Panagiotis 'Pano' Georgiadis

**Method:** OCI CLI (manual)

**Details:**
- Bucket Name: `terraform-state`
- Compartment: `ROOT/Tenancy Level` (not in any compartment)
- Namespace: `[Your Namespace]`
- Region: `[Your Region]`
- Versioning: Enabled (90-day retention)
- Public Access: Disabled
- Storage Tier: Standard
- Encryption: OCI-managed keys
- Lifecycle: 90-day version retention
- Backend Type: OCI Native Backend (Terraform >= 1.12.0)

**Purpose:**
- Stores Terraform state for deployment/ directory
- Contains state for 90+ OCI resources (42 IAM groups, 13 compartments)
- Critical infrastructure - DO NOT DELETE

**Protection:**
- Tagged with `DoNotDelete:true`
- IAM policies restrict deletion to OCI ADMINS only
- Lifecycle policy for version management
- Audit logging enabled
- Regular backups via OCI versioning

**Recovery:**
- If accidentally deleted, restore from OCI Object Storage versioning
- Contact OCI support for bucket recovery assistance
- Recreate manually using this documentation
- State can be recovered from latest version in bucket history

**Modification:**
- Changes to bucket configuration must be documented here
- Any lifecycle policy changes require team approval
- Versioning must never be disabled
- Document all changes in Git commit history

**Access:**
- IAM Group: `OCI ADMINS` (manage objects, manage buckets)
- IAM Group: `CIS-Auditors` (inspect only)
- All access logged via OCI Audit service
- State locking: Automatic via OCI native backend (ETag-based)

---

## Why OCI Object Storage for State? (vs. Alternatives)

### Architecture Decision: State Storage Location

**Decision:** Store Terraform state in OCI Object Storage using OCI native backend

**Rationale:** This infrastructure exclusively manages OCI resources within a single tenancy. Storing state in OCI provides significant advantages over alternative storage locations.

### Benefits Over Alternative Solutions

#### vs. Local Storage
| Aspect | OCI Object Storage | Local Storage |
|--------|-------------------|---------------|
| **Team Collaboration** | ✅ Multi-user access with locking | ❌ Single user, no sharing |
| **State Locking** | ✅ Automatic ETag-based locking | ❌ No locking mechanism |
| **Disaster Recovery** | ✅ Versioning, cross-region replication | ❌ Dependent on local backups |
| **Availability** | ✅ 99.9% SLA | ❌ Dependent on laptop/workstation |
| **Audit Trail** | ✅ OCI Audit service integration | ❌ No centralized auditing |
| **Access Control** | ✅ IAM policies, MFA enforcement | ❌ File system permissions only |

**Verdict:** Local storage is unsuitable for team environments and production infrastructure.

#### vs. Bitbucket / Git Repository
| Aspect | OCI Object Storage | Git Repository |
|--------|-------------------|----------------|
| **State Locking** | ✅ Native atomic locking | ❌ No native locking (race conditions) |
| **Security** | ✅ Encrypted at rest, access logs | ⚠️ State exposed in Git history |
| **Secrets Exposure** | ✅ Never leaves OCI network | ❌ Sensitive data in commit history |
| **Version Control** | ✅ Object versioning (90 days) | ✅ Git history (manual management) |
| **Size Limits** | ✅ No practical limits | ⚠️ Git performance degrades with large files |
| **Compliance** | ✅ Meets data residency requirements | ❌ Data may traverse external networks |

**Verdict:** Git repositories are designed for code, not stateful data. State files contain sensitive OCIDs and resource details that shouldn't be version-controlled in Git.

#### vs. Azure Blob Storage / AWS S3
| Aspect | OCI Object Storage | External Cloud Provider |
|--------|-------------------|------------------------|
| **Authentication** | ✅ Native OCI IAM, API keys, instance principals | ❌ Cross-cloud auth complexity |
| **Network Latency** | ✅ Same region as resources (~1-5ms) | ❌ Cross-cloud latency (50-200ms) |
| **Data Transfer Costs** | ✅ No egress charges (same cloud) | ❌ Cross-cloud egress fees ($0.05-0.09/GB) |
| **Security Boundary** | ✅ Same security perimeter as infrastructure | ❌ Separate security boundary, additional attack surface |
| **Compliance** | ✅ Data residency guaranteed (EU/Frankfurt) | ⚠️ May violate data residency requirements |
| **Vendor Lock-in** | ⚠️ OCI-specific | ⚠️ Multi-cloud dependency |
| **Operational Overhead** | ✅ Single platform to manage | ❌ Multi-cloud credential management |
| **Audit Integration** | ✅ Unified OCI Audit logs | ❌ Separate audit systems to monitor |
| **Cost** | ✅ $0.0255/GB/month (Standard) | Azure: $0.0184/GB (Hot), AWS: $0.023/GB (S3 Standard) |

**Verdict:** Using external cloud storage adds complexity, cost, and security risks without providing meaningful benefits for OCI-only infrastructure.

### OCI-Specific Advantages

1. **Native OCI Backend Integration**
   - Uses OCI SDK directly (no AWS compatibility layer)
   - Seamless authentication via OCI CLI config
   - ETag-based optimistic locking (no separate lock table needed)
   - Better error messages and debugging

2. **Security & Compliance**
   - State data never leaves OCI network
   - Inherits OCI IAM policies and audit logging
   - Meets US data residency requirements for insurance regulations
   - Compliant with NAIC Model Audit Rule (MAR) requirements
   - Supports SOC 2 Type II audit requirements
   - State insurance department data protection standards
   - Same encryption standards as managed resources
   - MFA enforcement via OCI IAM

3. **Performance & Reliability**
   - Sub-5ms latency (same US region)
   - 99.9% availability SLA matches infrastructure SLA
   - No cross-cloud network dependencies
   - Faster terraform init/plan/apply operations

4. **Cost Efficiency**
   - No cross-cloud data transfer fees
   - No additional authentication services needed
   - Standard tier: $0.0255/GB/month (256KB state ≈ $0.000007/month)
   - Versioning included in base price

5. **Operational Simplicity**
   - Single cloud platform to monitor and manage
   - Unified IAM and access control
   - One audit log system (OCI Audit)
   - Team uses existing OCI credentials
   - No additional vendor relationships

6. **Team Collaboration**
   - Automatic state locking prevents concurrent modifications
   - Each team member uses their own OCI credentials
   - Centralized state accessible from anywhere
   - No shared credentials required

### Cost Analysis (Annual)

**OCI Object Storage:**
- State file: 256KB × $0.0255/GB/month = $0.000007/month
- Versioning (90 days, ~10 versions): ~$0.00007/month
- API requests: ~$0.01/month (1000 operations)
- **Total: ~$0.12/year**

**Azure Blob Storage Alternative:**
- Storage: $0.0184/GB/month = $0.000005/month
- Egress to OCI: ~100 operations/day × $0.09/GB × 1MB = $2.70/month
- Cross-cloud latency impact: Priceless (slower operations)
- Additional auth service: $5-10/month (Azure AD integration)
- **Total: ~$90-150/year + operational overhead**

**ROI: OCI native storage saves ~$90-150/year while reducing complexity and improving performance.**

---

## CIS Compliance Notes

### Root Compartment Exception
The following resources are intentionally placed in the root compartment as foundational infrastructure required for Terraform operations:

- **terraform-state bucket**: Required for remote state storage before compartment hierarchy exists
  - Access: Restricted to OCI ADMINS group only
  - Encryption: Enabled with OCI-managed keys
  - Versioning: Enabled (90-day retention)
  - Public access: Disabled
  - Logging: Enabled via OCI Audit service

This is consistent with CIS OCI Foundations Benchmark v1.2 Section 1.14, which allows foundational resources necessary for bootstrap operations.

All other infrastructure resources are deployed in appropriate compartments per CIS guidelines.

### Additional CIS Controls Applied

- **CIS 1.1** - Ensure service level admins are created to manage resources (✅ OCI ADMINS group)
- **CIS 1.2** - Ensure permissions on resources are given only to the tenancy administrator (✅ IAM policies restrict state bucket)
- **CIS 1.14** - Ensure storage service-level admins cannot delete resources (✅ Lifecycle policies prevent accidental deletion)
- **CIS 3.1** - Ensure audit log retention period is set to 365 days (✅ OCI Audit logs enabled)
- **CIS 3.14** - Ensure Cloud Guard is enabled (✅ Monitors state bucket access)

---