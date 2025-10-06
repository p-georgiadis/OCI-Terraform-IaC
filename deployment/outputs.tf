# Consolidated outputs from all modules

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    groups_created = length(module.groups.group_names)
    compartments = {
      shared_services = module.shared_services.compartment_name
      saas_root       = module.saas_compartments.compartment_ids["SaaS-Root"]
      iaas_root       = module.iaas_compartments.iaas_root_compartment_id
    }
    policies_deployed = keys(module.policies.policy_ids)
    quotas_set        = keys(module.policies.quota_ids)
  }
}

output "group_ids" {
  description = "All group OCIDs"
  value       = module.groups.group_ids
}

output "compartment_structure" {
  description = "Complete compartment hierarchy"
  value = {
    shared_services = module.shared_services.compartment_id
    saas            = module.saas_compartments.compartment_tree
    iaas            = module.iaas_compartments.compartment_tree
  }
}

output "policy_ids" {
  description = "All policy OCIDs"
  value       = module.policies.policy_ids
}