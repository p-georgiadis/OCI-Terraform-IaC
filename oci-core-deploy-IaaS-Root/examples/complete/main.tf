module "iaas_root" {
  source = "../../"

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  # Optional: Enable environment separation when ready
  # create_environment_separation = true
}

# Variables
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Outputs
output "compartment_structure" {
  value       = module.iaas_root.compartment_tree
  description = "IaaS compartment hierarchy"
}

output "compartment_ids" {
  value = {
    root         = module.iaas_root.iaas_root_compartment_id
    network      = module.iaas_root.network_compartment_id
    applications = module.iaas_root.applications_compartment_id
    database     = module.iaas_root.database_compartment_id
  }
  description = "All IaaS compartment OCIDs"
}