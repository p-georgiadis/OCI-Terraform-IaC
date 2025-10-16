# All IAM Policies

# Tenancy-level Administrator policies
resource "oci_identity_policy" "admin_policies" {
  compartment_id = var.tenancy_ocid
  name           = "admin-tenancy-policies"
  description    = "Administrator policies for tenancy management"

  statements = [
    "Allow group Administrators to manage all-resources in tenancy",
  ]
}

# IAM Administrator policies
resource "oci_identity_policy" "iam_admin_policies" {
  compartment_id = var.tenancy_ocid
  name           = "iam-admin-policies"
  description    = "IAM administrator policies"

  statements = [
    "Allow group ${var.iam_admin_group} to manage users in tenancy",
    "Allow group ${var.iam_admin_group} to manage groups in tenancy",
    "Allow group ${var.iam_admin_group} to manage policies in tenancy",
    "Allow group ${var.iam_admin_group} to manage compartments in tenancy",
    "Allow group ${var.iam_admin_group} to read audit-events in tenancy",
    "Allow group ${var.iam_admin_group} to manage policies in compartment shared-services",
    "Allow group ${var.iam_admin_group} to read compartments in tenancy",
  ]
}

# Security Administrator policies for shared-services
resource "oci_identity_policy" "sec_admin_policies" {
  compartment_id = var.tenancy_ocid
  name           = "security-admin-policies"
  description    = "Security administrator policies for shared services"

  statements = [
    "Allow group ${var.sec_admin_group} to manage cloud-guard-family in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage log-groups in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage logs in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage serviceconnectors in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage streams in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage virtual-network-family in compartment shared-services",
    "Allow group ${var.sec_admin_group} to read metrics in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage vaults in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage keys in compartment shared-services",
    "Allow group ${var.sec_admin_group} to manage secret-family in compartment shared-services",
  ]
}

# EPM user policies
resource "oci_identity_policy" "epm_user_policies" {
  compartment_id = var.tenancy_ocid
  name           = "epm-user-policies"
  description    = "EPM user policies"
  
  statements = [
    "Allow group IAM_OCI_SECUREROLE_EPM_Users to use epm-planning-environment-family in compartment SaaS-Root:ARCS",
    "Allow group IAM_OCI_SECUREROLE_EPM_PowerUsers to manage epm-planning-environment-family in compartment SaaS-Root:ARCS",
    "Allow group IAM_OCI_SECUREROLE_Viewer to read all-resources in compartment SaaS-Root",
  ]
}


# EPM Service Administrator policies
resource "oci_identity_policy" "epm_service_admin_policies" {
  compartment_id = var.tenancy_ocid
  name           = "epm-service-admin-policies"
  description    = "EPM service administrator policies"
  
  statements = [
    "Allow group IAM_OCI_SECUREROLE_EPM_ServiceAdministrators to manage epm-planning-environment-family in compartment SaaS-Root:ARCS where request.permission != 'EPM_PLANNING_ENVIRONMENT_CREATE'",
    "Allow group IAM_OCI_SECUREROLE_EPM_ServiceAdministrators to read all-resources in compartment SaaS-Root:ARCS",
    "Allow group IAM_OCI_SECUREROLE_EPM_ServiceAdministrators to use cloud-shell in compartment SaaS-Root:ARCS",
  ]
}

# ARCS Production Admin policies
resource "oci_identity_policy" "arcs_prod_admin_policies" {
  count = var.deploy_arcs_policies ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  name           = "arcs-prod-admin-policies"
  description    = "ARCS production administrator policies"
  
  statements = [
    "Allow group ARCS-Prod-Admins to manage epm-planning-environment-family in compartment SaaS-Root:ARCS:ARCS-Prod",
    "Allow group ARCS-Prod-Admins to read all-resources in compartment SaaS-Root:ARCS:ARCS-Prod",
    # CIS 1.15: Prevent deletion of storage resources (buckets and objects)
    "Allow group ARCS-Prod-Admins to manage object-family in compartment SaaS-Root:ARCS:ARCS-Prod where all {target.bucket.name = 'arcs-prod-*', request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
  ]
}

# ARCS Test Admin policies
resource "oci_identity_policy" "arcs_test_admin_policies" {
  count = var.deploy_arcs_policies ? 1 : 0
  
  compartment_id = var.tenancy_ocid
  name           = "arcs-test-admin-policies"
  description    = "ARCS test administrator policies"
  
  statements = [
    "Allow group ARCS-Test-Admins to manage epm-planning-environment-family in compartment SaaS-Root:ARCS:ARCS-Test",
    "Allow group ARCS-Test-Admins to read all-resources in compartment SaaS-Root:ARCS:ARCS-Test",
    # CIS 1.15: Prevent deletion of storage resources (buckets and objects)
    "Allow group ARCS-Test-Admins to manage object-family in compartment SaaS-Root:ARCS:ARCS-Test where all {target.bucket.name = 'arcs-test-*', request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
  ]
}

# Finance Auditor policies
resource "oci_identity_policy" "finance_auditor_policies" {
  compartment_id = var.tenancy_ocid
  name           = "finance-auditor-policies"
  description    = "Finance auditor read-only policies"
  
  statements = [
    "Allow group Finance-Auditors to read all-resources in compartment SaaS-Root",
    "Allow group Finance-Auditors to read audit-events in compartment SaaS-Root",
    "Allow group Finance_ReadOnly to read all-resources in compartment SaaS-Root",
  ]
}

# Future IaaS Network Admin policies (placeholder)
resource "oci_identity_policy" "network_admin_policies" {
  count = var.deploy_iaas_policies ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "network-admin-policies"
  description    = "Network administrator policies for IaaS"

  statements = [
    "Allow group NetworkAdmins to manage virtual-network-family in compartment IaaS-Root:Network",
    "Allow group NetworkAdmins to manage load-balancers in compartment IaaS-Root:Network",
    "Allow group NetworkAdmins to manage network-security-groups in compartment IaaS-Root:Network",
    "Allow group NetworkAdmins to read compartments in compartment IaaS-Root",
  ]
}

# Future IaaS Database Admin policies (placeholder)
resource "oci_identity_policy" "database_admin_policies" {
  count = var.deploy_iaas_policies ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "database-admin-policies"
  description    = "Database administrator policies for IaaS"

  statements = [
    "Allow group DBAdmins to manage database-family in compartment IaaS-Root:Database",
    "Allow group DBAdmins to manage autonomous-database-family in compartment IaaS-Root:Database",
    # CIS 1.15: Prevent deletion of storage resources (buckets and objects)
    "Allow group DBAdmins to manage object-family in compartment IaaS-Root:Database where all {request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "Allow group DBAdmins to read compartments in compartment IaaS-Root",
  ]
}

# CIS Auditor policies for compliance checking
resource "oci_identity_policy" "cis_auditor_policies" {
  compartment_id = var.tenancy_ocid
  name           = "cis-auditor-policies"
  description    = "CIS compliance script auditor policies"
  
  statements = [
    "Allow group CIS-Auditors to inspect all-resources in tenancy",
    "Allow group CIS-Auditors to read instances in tenancy",
    "Allow group CIS-Auditors to read load-balancers in tenancy",
    "Allow group CIS-Auditors to read buckets in tenancy",
    "Allow group CIS-Auditors to read nat-gateways in tenancy",
    "Allow group CIS-Auditors to read public-ips in tenancy",
    "Allow group CIS-Auditors to read file-family in tenancy",
    "Allow group CIS-Auditors to read instance-configurations in tenancy",
    "Allow group CIS-Auditors to read network-security-groups in tenancy",
    "Allow group CIS-Auditors to read capture-filters in tenancy",
    "Allow group CIS-Auditors to read resource-availability in tenancy",
    "Allow group CIS-Auditors to read audit-events in tenancy",
    "Allow group CIS-Auditors to read users in tenancy",
    "Allow group CIS-Auditors to use cloud-shell in tenancy",
    "Allow group CIS-Auditors to read vss-family in tenancy",
    "Allow group CIS-Auditors to read usage-budgets in tenancy",
    "Allow group CIS-Auditors to read usage-reports in tenancy",
    "Allow group CIS-Auditors to read data-safe-family in tenancy",
    "Allow group CIS-Auditors to read vaults in tenancy",
    "Allow group CIS-Auditors to read keys in tenancy",
    "Allow group CIS-Auditors to read tag-namespaces in tenancy",
    "Allow group CIS-Auditors to use ons-family in tenancy where any {request.operation!=/Create*/, request.operation!=/Update*/, request.operation!=/Delete*/, request.operation!=/Change*/}",
  ]
}