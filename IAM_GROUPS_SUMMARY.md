# IAM Groups Summary - Hanover OCI Tenancy

This document provides a comprehensive overview of all 42 IAM groups deployed in the Hanover OCI tenancy, their purposes, and associated policies.

**Total Groups Created**: 42
**Last Updated**: 2025-10-16

---

## Table of Contents

1. [Administrative Groups](#administrative-groups)
2. [EPM Application Groups](#epm-application-groups)
3. [ARCS Functional Role Groups](#arcs-functional-role-groups)
4. [Finance & Audit Groups](#finance--audit-groups)
5. [Infrastructure Groups (Future Use)](#infrastructure-groups-future-use)
6. [Groups Without Active Policies](#groups-without-active-policies)

---

## Administrative Groups

### 1. **Administrators** (Built-in OCI Group)
**Owner**: Tenancy Root
**Environment**: Production
**Policy**: `admin-tenancy-policies`

**Purpose**: Break-glass tenancy-level administrators with full access to all OCI resources.

**Permissions**:
- ✅ Manage all resources in tenancy
- ✅ Full administrative control
- ✅ Break-glass emergency access

**Use Case**: Emergency access, initial tenancy setup, critical operations requiring full privileges.

**CIS Compliance Notes**:
- ⚠️ Users in this group should NOT have API keys (CIS 1.12)
- ✅ This is the ONLY group with tenancy-wide manage access (CIS 1.2)

---

### 2. **IAM_OCI_SECUREROLE_IAMAdmins**
**Owner**: IAM Team
**Environment**: Production
**Policy**: `iam-admin-policies`

**Purpose**: IAM administrators responsible for user, group, and policy management.

**Permissions**:
- ✅ Manage users in tenancy
- ✅ Manage groups in tenancy
- ✅ Manage policies in tenancy
- ✅ Manage compartments in tenancy
- ✅ Read audit-events in tenancy
- ✅ Manage policies in shared-services compartment
- ✅ Read compartments in tenancy

**Use Case**: Day-to-day IAM administration, user onboarding/offboarding, group membership management.

**Restrictions**:
- ❌ Cannot manage the Administrators group (enforced by policy conditions - would need to be added)
- ❌ Cannot create/delete tenancy-level resources outside IAM

---

### 3. **IAM_OCI_SECUREROLE_SECAdmins**
**Owner**: Security Team
**Environment**: Production
**Policy**: `security-admin-policies`

**Purpose**: Security administrators managing Cloud Guard, logging, monitoring, and security infrastructure.

**Permissions** (in shared-services compartment):
- ✅ Manage cloud-guard-family
- ✅ Manage log-groups
- ✅ Manage logs
- ✅ Manage serviceconnectors
- ✅ Manage streams
- ✅ Manage virtual-network-family
- ✅ Read metrics
- ✅ Manage vaults
- ✅ Manage keys
- ✅ Manage secret-family

**Use Case**: Security monitoring setup, log aggregation, SIEM integration, Cloud Guard configuration.

**Scope**: Limited to `shared-services` compartment only.

---

### 4. **EPM_Admins**
**Owner**: IAM Team
**Environment**: Production
**Policy**: No specific policy assigned yet

**Purpose**: General EPM environment administrators.

**Status**: ⚠️ Group created but no policies assigned yet. Reserved for future EPM cross-module administration.

---

## EPM Application Groups

### 5. **IAM_OCI_SECUREROLE_EPM_ServiceAdministrators**
**Owner**: Finance
**Environment**: Production
**Policy**: `epm-service-admin-policies`

**Purpose**: EPM service-level administrators who can manage EPM environments but cannot create new ones.

**Permissions** (in SaaS-Root:ARCS):
- ✅ Manage epm-planning-environment-family (except CREATE)
- ✅ Read all-resources
- ✅ Use cloud-shell

**Use Case**: Day-to-day EPM administration, configuration changes, service management.

**Restrictions**:
- ❌ Cannot create new EPM environments (requires Administrators or specific permission)

**CIS Compliance**: ✅ Separation of duties - admins can manage but not create.

---

### 6. **IAM_OCI_SECUREROLE_EPM_PowerUsers**
**Owner**: Finance
**Environment**: Production
**Policy**: `epm-user-policies`

**Purpose**: Power users with full management capabilities within EPM applications.

**Permissions** (in SaaS-Root:ARCS):
- ✅ Manage epm-planning-environment-family

**Use Case**: Advanced EPM users who need to configure and manage EPM instances.

---

### 7. **IAM_OCI_SECUREROLE_EPM_Users**
**Owner**: Finance
**Environment**: Production
**Policy**: `epm-user-policies`

**Purpose**: Standard EPM application users.

**Permissions** (in SaaS-Root:ARCS):
- ✅ Use epm-planning-environment-family (read/execute)

**Use Case**: Regular EPM users performing daily tasks.

**Restrictions**:
- ❌ Cannot modify EPM configurations
- ❌ Cannot create/delete resources

---

### 8. **IAM_OCI_SECUREROLE_Viewer**
**Owner**: Finance
**Environment**: Production
**Policy**: `epm-user-policies`

**Purpose**: Read-only viewers across all SaaS applications.

**Permissions**:
- ✅ Read all-resources in SaaS-Root compartment

**Use Case**: Stakeholders, managers, auditors who need visibility without modification rights.

---

## ARCS-Specific Administration Groups

### 9. **ARCS-Prod-Admins**
**Owner**: Finance
**Environment**: Production
**Policy**: `arcs-prod-admin-policies`

**Purpose**: Administrators for ARCS production environment.

**Permissions** (in SaaS-Root:ARCS:ARCS-Prod):
- ✅ Manage epm-planning-environment-family
- ✅ Read all-resources
- ✅ Manage object-family (buckets matching 'arcs-prod-*')

**Use Case**: Production ARCS environment management, configuration, backups.

**CIS 1.15 Compliance** ✅:
- ✅ Can create/modify buckets and objects
- ❌ **Cannot delete buckets** (BUCKET_DELETE restricted)
- ❌ **Cannot delete objects** (OBJECT_DELETE restricted)

**Security Feature**: Deletion requires escalation to Administrators group (separation of duties).

---

### 10. **ARCS-Test-Admins**
**Owner**: Finance
**Environment**: Test/UAT
**Policy**: `arcs-test-admin-policies`

**Purpose**: Administrators for ARCS test/UAT environment.

**Permissions** (in SaaS-Root:ARCS:ARCS-Test):
- ✅ Manage epm-planning-environment-family
- ✅ Read all-resources
- ✅ Manage object-family (buckets matching 'arcs-test-*')

**Use Case**: Test environment management, UAT support, development testing.

**CIS 1.15 Compliance** ✅:
- ✅ Can create/modify buckets and objects
- ❌ **Cannot delete buckets** (BUCKET_DELETE restricted)
- ❌ **Cannot delete objects** (OBJECT_DELETE restricted)

---

### 11. **ARCS_Users**
**Owner**: ARCS Lead
**Environment**: Test
**Policy**: No specific policy assigned

**Purpose**: General ARCS application users.

**Status**: ⚠️ Group created but no specific OCI permissions. Likely used for EPM application-level roles only.

---

## ARCS Functional Role Groups

These 27 groups map to specific ARCS application roles. They are created in OCI IAM but primarily managed at the EPM application level.

### Access Control

#### 12. **IAM_OCI_SECUREROLE_EPM_ARCS_AccessControlManage**
**Purpose**: Manage access control settings within ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 13. **IAM_OCI_SECUREROLE_EPM_ARCS_AccessControlView**
**Purpose**: View access control settings within ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Alerts & Announcements

#### 14. **IAM_OCI_SECUREROLE_EPM_ARCS_AlertTypesManage**
**Purpose**: Manage alert type configurations in ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 15. **IAM_OCI_SECUREROLE_EPM_ARCS_AnnouncementsManage**
**Purpose**: Manage system announcements in ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Audit & Compliance

#### 16. **IAM_OCI_SECUREROLE_EPM_ARCS_AuditView**
**Purpose**: View audit trails and logs within ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Configuration Management

#### 17. **IAM_OCI_SECUREROLE_EPM_ARCS_CurrenciesManage**
**Purpose**: Manage currency configurations for reconciliations
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 18. **IAM_OCI_SECUREROLE_EPM_ARCS_PeriodsManage**
**Purpose**: Manage accounting periods in ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 19. **IAM_OCI_SECUREROLE_EPM_ARCS_PeriodsView**
**Purpose**: View accounting periods (read-only)
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 20. **IAM_OCI_SECUREROLE_EPM_ARCS_OrganizationsManage**
**Purpose**: Manage organizational hierarchies in ARCS
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 21. **IAM_OCI_SECUREROLE_EPM_ARCS_TeamsManage**
**Purpose**: Manage team assignments and structures
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Data Integration

#### 22. **IAM_OCI_SECUREROLE_EPM_ARCS_DataIntegrationAdministrator**
**Purpose**: Full administration of data integration processes
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 23. **IAM_OCI_SECUREROLE_EPM_ARCS_DataIntegrationCreate**
**Purpose**: Create new data integration jobs and mappings
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 24. **IAM_OCI_SECUREROLE_EPM_ARCS_DataIntegrationRun**
**Purpose**: Execute existing data integration jobs
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 25. **IAM_OCI_SECUREROLE_EPM_ARCS_DataLoadsManage**
**Purpose**: Manage data load processes and schedules
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Jobs & Monitoring

#### 26. **IAM_OCI_SECUREROLE_EPM_ARCS_JobsView**
**Purpose**: View job statuses and execution history
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Match Types

#### 27. **IAM_OCI_SECUREROLE_EPM_ARCS_MatchTypesManage**
**Purpose**: Manage reconciliation match types and rules
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 28. **IAM_OCI_SECUREROLE_EPM_ARCS_MatchTypesView**
**Purpose**: View match types (read-only)
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Migrations

#### 29. **IAM_OCI_SECUREROLE_EPM_ARCS_MigrationsAdministrator**
**Purpose**: Administer data migrations and snapshots
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Profiles & Reconciliations

#### 30. **IAM_OCI_SECUREROLE_EPM_ARCS_ProfilesView**
**Purpose**: View reconciliation profiles (read-only)
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 31. **IAM_OCI_SECUREROLE_EPM_ARCS_ProfilesandReconciliationsManage**
**Purpose**: Full management of profiles and reconciliations
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 32. **IAM_OCI_SECUREROLE_EPM_ARCS_ReconciliationCommentator**
**Purpose**: Add comments to reconciliations
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 33. **IAM_OCI_SECUREROLE_EPM_ARCS_ReconciliationPreparer**
**Purpose**: Prepare and submit reconciliations
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 34. **IAM_OCI_SECUREROLE_EPM_ARCS_ReconciliationReviewer**
**Purpose**: Review and approve reconciliations
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### Reporting & Dashboards

#### 35. **IAM_OCI_SECUREROLE_EPM_ARCS_DashboardsManage**
**Purpose**: Create and manage ARCS dashboards
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 36. **IAM_OCI_SECUREROLE_EPM_ARCS_ReportsManage**
**Purpose**: Create and manage ARCS reports
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

#### 37. **IAM_OCI_SECUREROLE_EPM_ARCS_PublicFiltersandViewsManage**
**Purpose**: Manage shared filters and views
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

### User Management

#### 38. **IAM_OCI_SECUREROLE_EPM_ARCS_UsersManage**
**Purpose**: Manage ARCS application user settings
**Owner**: Finance
**OCI Policy**: None (EPM application-level role)

---

## Finance & Audit Groups

### 39. **Finance-Auditors**
**Owner**: Finance
**Environment**: Production
**Policy**: `finance-auditor-policies`

**Purpose**: Finance team members with audit capabilities.

**Permissions**:
- ✅ Read all-resources in SaaS-Root compartment
- ✅ Read audit-events in SaaS-Root compartment

**Use Case**: Financial audits, compliance reviews, data verification.

**Restrictions**:
- ❌ Cannot modify any resources
- ❌ Read-only access

---

### 40. **Finance_ReadOnly**
**Owner**: Finance
**Environment**: Production
**Policy**: `finance-auditor-policies`

**Purpose**: Read-only access for finance team members.

**Permissions**:
- ✅ Read all-resources in SaaS-Root compartment

**Use Case**: Finance stakeholders who need visibility into EPM resources.

**Restrictions**:
- ❌ Cannot modify any resources
- ❌ Cannot read audit events (use Finance-Auditors for that)

---

### 41. **CIS-Auditors**
**Owner**: Security Team
**Environment**: Production
**Policy**: `cis-auditor-policies`

**Purpose**: CIS compliance script auditors with tenancy-wide read permissions.

**Permissions** (Tenancy-wide):
- ✅ Inspect all-resources
- ✅ Read instances, load-balancers, buckets, networking, file-family
- ✅ Read instance-configurations, network-security-groups
- ✅ Read resource-availability
- ✅ Read audit-events
- ✅ Read users
- ✅ Use cloud-shell
- ✅ Read vss-family (vulnerability scanning)
- ✅ Read usage-budgets and usage-reports
- ✅ Read data-safe-family
- ✅ Read vaults, keys, secrets
- ✅ Read tag-namespaces
- ✅ Use ons-family (notifications) - read-only

**Use Case**: Running CIS compliance scans, security audits, compliance reporting.

**Restrictions**:
- ❌ Cannot create, update, delete, or change any resources
- ❌ Read-only access across entire tenancy

**Scripts**: Use with `cis_reports.py` for automated compliance scanning.

---

## Infrastructure Groups (Future Use)

These groups are created but have **no active policies** yet (policies are disabled via `deploy_iaas_policies = false`).

### 42. **NetworkAdmins**
**Owner**: Network Team
**Environment**: Production
**Policy**: `network-admin-policies` (DISABLED)

**Purpose**: Network administrators for future IaaS infrastructure.

**Future Permissions** (when enabled):
- Manage virtual-network-family in IaaS-Root:Network
- Manage load-balancers in IaaS-Root:Network
- Manage network-security-groups in IaaS-Root:Network
- Read compartments in IaaS-Root

**Status**: ⚠️ Group created, policies defined but not deployed. Enable with `enable_iaas_policies = true`.

---

### 43. **DBAdmins**
**Owner**: DBA Team
**Environment**: Production
**Policy**: `database-admin-policies` (DISABLED)

**Purpose**: Database administrators for future IaaS databases.

**Future Permissions** (when enabled, in IaaS-Root:Database):
- Manage database-family
- Manage autonomous-database-family
- Manage object-family (with delete restrictions per CIS 1.15)
- Read compartments in IaaS-Root

**CIS 1.15 Compliance** (when enabled):
- ✅ Can create/modify buckets and objects
- ❌ **Cannot delete buckets** (BUCKET_DELETE restricted)
- ❌ **Cannot delete objects** (OBJECT_DELETE restricted)

**Status**: ⚠️ Group created, policies defined but not deployed. Enable with `enable_iaas_policies = true`.

---

## Groups Without Active Policies

The following groups are created but have no OCI-level policies assigned:

| Group | Purpose | Notes |
|-------|---------|-------|
| EPM_Admins | General EPM administration | Reserved for future use |
| ARCS_Users | General ARCS users | EPM application-level role only |
| All 27 ARCS functional roles | Specific ARCS capabilities | EPM application-level roles only |

**Why no OCI policies?**
These groups are used for EPM application-level authorization. OCI IAM recognizes them for federated identity purposes, but their permissions are managed within the EPM application itself.

---

## Policy Summary Table

| Policy Name | Groups Covered | Scope | CIS Compliant |
|-------------|----------------|-------|---------------|
| admin-tenancy-policies | Administrators | Tenancy-wide | ✅ |
| iam-admin-policies | IAM_OCI_SECUREROLE_IAMAdmins | Tenancy-wide | ✅ |
| security-admin-policies | IAM_OCI_SECUREROLE_SECAdmins | shared-services | ✅ |
| epm-user-policies | EPM_Users, EPM_PowerUsers, Viewer | SaaS-Root:ARCS | ✅ |
| epm-service-admin-policies | EPM_ServiceAdministrators | SaaS-Root:ARCS | ✅ |
| arcs-prod-admin-policies | ARCS-Prod-Admins | ARCS-Prod | ✅ CIS 1.15 |
| arcs-test-admin-policies | ARCS-Test-Admins | ARCS-Test | ✅ CIS 1.15 |
| finance-auditor-policies | Finance-Auditors, Finance_ReadOnly | SaaS-Root | ✅ |
| cis-auditor-policies | CIS-Auditors | Tenancy-wide (read-only) | ✅ |
| network-admin-policies | NetworkAdmins | IaaS-Root:Network | ⚠️ Disabled |
| database-admin-policies | DBAdmins | IaaS-Root:Database | ⚠️ Disabled |

---

## Best Practices & Recommendations

### User Assignment
1. **Least Privilege**: Assign users to the most restrictive group that meets their needs
2. **Multiple Groups**: Users can be in multiple groups - permissions are additive
3. **Admin Groups**: Minimize membership in Administrators and IAM_OCI_SECUREROLE_IAMAdmins
4. **Service Accounts**: Use service-level groups (ARCS-*-Admins, EPM_ServiceAdministrators) for automation

### CIS Compliance
1. **CIS 1.12**: Do NOT assign API keys to users in Administrators group
2. **CIS 1.15**: Storage admin groups have delete restrictions - use Administrators for deletions
3. **CIS 1.1-1.3**: Service-level admin structure is implemented correctly

### Security
1. **Separation of Duties**: Production (ARCS-Prod-Admins) and Test (ARCS-Test-Admins) are separate
2. **Audit Trail**: CIS-Auditors can review but not modify
3. **Read-Only Groups**: Finance-Auditors and Finance_ReadOnly for stakeholder visibility

### Future Enhancements
1. **IaaS Activation**: Set `enable_iaas_policies = true` when ready to use IaaS infrastructure
2. **EPM Policies**: Add OCI-level policies for EPM functional roles if needed
3. **Custom Roles**: Create additional groups for specific use cases as needed

---

## Maintenance

### Adding Users to Groups
```bash
# Via OCI Console
Identity → Domains → Default → Groups → [Group Name] → Add User

# Via OCI CLI
oci iam group add-user --group-id <group-ocid> --user-id <user-ocid>
```

### Adding New Groups
1. Edit `oci-core-deploy-groups/csv_groups.csv`
2. Add line: `GroupName,Description,Environment,Owner`
3. Run `terraform apply` from `deployment/`

### Modifying Policies
1. Edit `oci-core-policies/policies.tf`
2. Update the relevant `statements` array
3. Run `terraform apply` from `deployment/`

---

## Support & Documentation

- **Policy Reference**: [oci-core-policies/policies.tf](oci-core-policies/policies.tf)
- **Group Definition**: [oci-core-deploy-groups/csv_groups.csv](oci-core-deploy-groups/csv_groups.csv)
- **Deployment Guide**: [QUICKSTART.md](QUICKSTART.md)
- **CIS Compliance**: [CIS_COMPLIANCE_IMPROVEMENTS.md](CIS_COMPLIANCE_IMPROVEMENTS.md)
