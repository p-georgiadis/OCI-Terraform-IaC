# Shared Services Compartment Module
# Creates compartment for shared OCI services

locals {
  compartment_name = var.compartment_name != "" ? var.compartment_name : "shared-services"
}

resource "oci_identity_compartment" "shared_services" {
  compartment_id = var.tenancy_ocid
  name           = local.compartment_name
  description    = var.compartment_description
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    var.freeform_tags
  )

  defined_tags = var.defined_tags
}

# Wait for IAM propagation
resource "time_sleep" "wait_for_compartment" {
  depends_on      = [oci_identity_compartment.shared_services]
  create_duration = "60s"
}