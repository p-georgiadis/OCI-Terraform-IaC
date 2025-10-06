# OCI Core Policies Module
# Consolidates all IAM policies, quotas, and tags for Hanover EPM implementation

# Data sources to get compartment OCIDs
data "oci_identity_compartments" "all" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  access_level              = "ANY"
}

locals {
  # Map compartment names to OCIDs
  compartment_map = {
    for c in data.oci_identity_compartments.all.compartments :
    c.name => c.id
  }
}