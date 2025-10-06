output "iaas_root_compartment_id" {
  description = "OCID of the IaaS-Root compartment"
  value       = oci_identity_compartment.iaas_root.id
}

output "network_compartment_id" {
  description = "OCID of the Network compartment"
  value       = oci_identity_compartment.network.id
}

output "applications_compartment_id" {
  description = "OCID of the Applications compartment"
  value       = oci_identity_compartment.applications.id
}

output "database_compartment_id" {
  description = "OCID of the Database compartment"
  value       = oci_identity_compartment.database.id
}

output "compartment_tree" {
  description = "Complete IaaS compartment structure"
  value = {
    root         = oci_identity_compartment.iaas_root.name
    network      = oci_identity_compartment.network.name
    applications = oci_identity_compartment.applications.name
    database     = oci_identity_compartment.database.name
    environments = var.create_environment_separation ? keys(oci_identity_compartment.app_environments) : []
  }
}