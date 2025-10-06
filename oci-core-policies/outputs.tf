output "policy_ids" {
  description = "Map of policy names to OCIDs"
  value = {
    admin           = oci_identity_policy.admin_policies.id
    iam_admin       = oci_identity_policy.iam_admin_policies.id
    sec_admin       = oci_identity_policy.sec_admin_policies.id
    epm_service     = oci_identity_policy.epm_service_admin_policies.id
    arcs_prod       = try(oci_identity_policy.arcs_prod_admin_policies[0].id, null)
    arcs_test       = try(oci_identity_policy.arcs_test_admin_policies[0].id, null)
    finance_auditor = oci_identity_policy.finance_auditor_policies.id
    epm_user        = oci_identity_policy.epm_user_policies.id
  }
}

output "quota_ids" {
  description = "Map of quota names to OCIDs"
  value = {
    saas_restrictions = oci_limits_quota.saas_restrictions.id
    iaas_restrictions = oci_limits_quota.iaas_restrictions.id
    shared_services_restrictions = oci_limits_quota.shared_services_restrictions.id
  }
}

output "tag_namespace_id" {
  description = "Operations tag namespace OCID"
  value       = oci_identity_tag_namespace.operations.id
}

output "tag_ids" {
  description = "Map of tag names to OCIDs"
  value = {
    cost_center = oci_identity_tag.cost_center.id
    environment = oci_identity_tag.environment.id
    application = oci_identity_tag.application.id
  }
}