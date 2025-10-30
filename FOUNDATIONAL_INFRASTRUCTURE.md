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
- Versioning: Enabled
- Public Access: Disabled
- Storage Tier: Standard
- Lifecycle: 90-day version retention

**Purpose:**
- Stores Terraform state for deployment/ directory
- Contains state for 90+ OCI resources
- Critical infrastructure - DO NOT DELETE

**Protection:**
- Tagged with `DoNotDelete:true`
- IAM policies restrict deletion
- Lifecycle policy for version management
- Regular backups required

**Recovery:**
- If accidentally deleted, restore from OCI audit logs or backups
- Contact OCI support for possible bucket recovery
- Recreate manually using this documentation

**Modification:**
- Changes to bucket configuration must be documented here
- Any lifecycle policy changes require team approval
- Versioning must never be disabled

**Access:**
- IAM Group: `IAM_OCI_SECUREROLE_IAMAdmins` (read/write)
- IAM Group: `CIS-Auditors` (read-only)
- All access logged via OCI Audit

**Related Documentation:**
- TERRAFORM_REMOTE_STATE_SETUP.md - Setup procedures
- Backend configuration: deployment/backend.tf

**Last Updated:** 2025-10-30
**Next Review:** Annual (or when changes are made)
