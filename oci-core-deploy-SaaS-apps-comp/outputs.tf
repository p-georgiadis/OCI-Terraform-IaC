output "compartment_ids" {
  value       = module.saas_apps.compartment_ids
  description = "Map of compartment names to OCIDs"
}

output "compartment_tree" {
  value = {
    saas_root_id        = module.saas_apps.compartment_ids["SaaS-Root"]
    arcs_compartment_id = module.saas_apps.compartment_ids["ARCS"]
    arcs_prod_id        = module.saas_apps.compartment_ids["ARCS-Prod"]
    arcs_test_id        = module.saas_apps.compartment_ids["ARCS-Test"]
    other_epm_id        = module.saas_apps.compartment_ids["Other-EPM"]
  }
  description = "Structured compartment IDs for reference"
}