module "groups" {
  source = "../../"

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  use_csv = true # Will use csv_groups.csv from module root
}

# Variables
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Outputs
output "all_groups" {
  value = module.groups.group_names
}

output "groups_by_owner" {
  value = module.groups.groups_by_owner
}
