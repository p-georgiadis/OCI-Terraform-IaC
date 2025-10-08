# Cloud Guard Configuration
# CIS Recommendation 4.14: Enable Cloud Guard in root compartment

# Enable Cloud Guard (must be done once per tenancy)
resource "oci_cloud_guard_cloud_guard_configuration" "cloud_guard_config" {
  compartment_id   = var.tenancy_ocid
  reporting_region = var.region
  status           = "ENABLED"

  # Self-manage resources is recommended to allow Cloud Guard to remediate issues
  self_manage_resources = var.cloud_guard_self_manage_resources
}

# Create Cloud Guard Target for root compartment
# This monitors the entire tenancy including all child compartments
resource "oci_cloud_guard_target" "root_target" {
  compartment_id       = var.tenancy_ocid
  display_name         = var.cloud_guard_target_name
  target_resource_id   = var.tenancy_ocid
  target_resource_type = "COMPARTMENT"

  description = "Cloud Guard target for root compartment - monitors entire tenancy for CIS compliance"

  # Use Oracle-managed detector recipes (recommended for CIS compliance)
  target_detector_recipes {
    detector_recipe_id = var.cloud_guard_configuration_detector_recipe_id != "" ? var.cloud_guard_configuration_detector_recipe_id : data.oci_cloud_guard_detector_recipes.oracle_managed_configuration.detector_recipe_collection[0].items[0].id
  }

  target_detector_recipes {
    detector_recipe_id = var.cloud_guard_activity_detector_recipe_id != "" ? var.cloud_guard_activity_detector_recipe_id : data.oci_cloud_guard_detector_recipes.oracle_managed_activity.detector_recipe_collection[0].items[0].id
  }

  target_detector_recipes {
    detector_recipe_id = var.cloud_guard_threat_detector_recipe_id != "" ? var.cloud_guard_threat_detector_recipe_id : data.oci_cloud_guard_detector_recipes.oracle_managed_threat.detector_recipe_collection[0].items[0].id
  }

  # Use Oracle-managed responder recipe for automated remediation
  target_responder_recipes {
    responder_recipe_id = var.cloud_guard_responder_recipe_id != "" ? var.cloud_guard_responder_recipe_id : data.oci_cloud_guard_responder_recipes.oracle_managed.responder_recipe_collection[0].items[0].id
  }

  depends_on = [oci_cloud_guard_cloud_guard_configuration.cloud_guard_config]

  freeform_tags = var.freeform_tags
}

# Data sources to get Oracle-managed recipes
data "oci_cloud_guard_detector_recipes" "oracle_managed_configuration" {
  compartment_id = var.tenancy_ocid
  display_name   = "OCI Configuration Detector Recipe"
}

data "oci_cloud_guard_detector_recipes" "oracle_managed_activity" {
  compartment_id = var.tenancy_ocid
  display_name   = "OCI Activity Detector Recipe"
}

data "oci_cloud_guard_detector_recipes" "oracle_managed_threat" {
  compartment_id = var.tenancy_ocid
  display_name   = "OCI Threat Detector Recipe"
}

data "oci_cloud_guard_responder_recipes" "oracle_managed" {
  compartment_id = var.tenancy_ocid
  display_name   = "OCI Responder Recipe"
}
