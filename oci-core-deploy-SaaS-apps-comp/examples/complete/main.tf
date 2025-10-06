module "saas_compartments" {
  source = "../../"

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

output "compartment_tree" {
  value       = module.saas_compartments.compartment_tree
  description = "Compartment hierarchy with OCIDs"
}
