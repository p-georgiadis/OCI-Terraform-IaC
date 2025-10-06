output "compartment_id" {
  description = "OCID of the shared-services compartment"
  value       = oci_identity_compartment.shared_services.id
}

output "compartment_name" {
  description = "Name of the shared-services compartment"
  value       = oci_identity_compartment.shared_services.name
}

output "compartment_path" {
  description = "Full path of the compartment"
  value       = "/${oci_identity_compartment.shared_services.name}"
}