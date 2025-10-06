# IaaS-Root Compartment Module
# Creates compartment structure for future infrastructure workloads
# CIS compliant with proper isolation

locals {
  compartment_name = var.compartment_name != "" ? var.compartment_name : "IaaS-Root"
}

# Root compartment for all IaaS resources
resource "oci_identity_compartment" "iaas_root" {
  compartment_id = var.tenancy_ocid
  name           = local.compartment_name
  description    = var.compartment_description
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    var.freeform_tags
  )
}

# Network compartment - CIS recommends network isolation
resource "oci_identity_compartment" "network" {
  compartment_id = oci_identity_compartment.iaas_root.id
  name           = "Network"
  description    = "Network resources - VCNs, Subnets, Gateways, Load Balancers (Future Use)"
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    {
      Purpose = "Network-Infrastructure",
      CIS     = "Network-Isolation",
      Status  = "Reserved-Future-Use"
    }
  )
}

# Applications compartment - For compute and app resources
resource "oci_identity_compartment" "applications" {
  compartment_id = oci_identity_compartment.iaas_root.id
  name           = "Applications"
  description    = "Application compute resources - VMs, Containers, Functions (Future Use)"
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    {
      Purpose = "Application-Workloads",
      Status  = "Reserved-Future-Use"
    }
  )
}

# Database compartment - CIS recommends database isolation
resource "oci_identity_compartment" "database" {
  compartment_id = oci_identity_compartment.iaas_root.id
  name           = "Database"
  description    = "Database resources - Autonomous DB, MySQL, NoSQL (Future Use)"
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    {
      Purpose = "Database-Infrastructure",
      CIS     = "Database-Isolation",
      Status  = "Reserved-Future-Use"
    }
  )
}

# Optional: Environment-based sub-compartments under Applications
resource "oci_identity_compartment" "app_environments" {
  for_each = var.create_environment_separation ? var.application_environments : {}

  compartment_id = oci_identity_compartment.applications.id
  name           = each.key
  description    = each.value.description
  enable_delete  = var.enable_delete

  freeform_tags = merge(
    var.default_tags,
    {
      Environment = each.key,
      Purpose     = each.value.purpose,
      Status      = "Reserved-Future-Use"
    }
  )
}

# Wait for IAM propagation
resource "time_sleep" "wait_for_compartments" {
  depends_on = [
    oci_identity_compartment.iaas_root,
    oci_identity_compartment.network,
    oci_identity_compartment.applications,
    oci_identity_compartment.database,
    oci_identity_compartment.app_environments
  ]
  create_duration = "60s"
}