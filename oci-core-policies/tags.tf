# Tag namespace for operational governance

resource "oci_identity_tag_namespace" "operations" {
  compartment_id = var.tenancy_ocid
  name           = "Operations"
  description    = "Operational tags for resource management and cost tracking"
}

# Cost Center tag for billing
resource "oci_identity_tag" "cost_center" {
  tag_namespace_id = oci_identity_tag_namespace.operations.id
  name             = "CostCenter"
  description      = "Cost center for billing and chargeback"
  is_cost_tracking = true

  validator {
    validator_type = "ENUM"
    values         = var.cost_center_values
  }
}

# Environment tag for resource classification
resource "oci_identity_tag" "environment" {
  tag_namespace_id = oci_identity_tag_namespace.operations.id
  name             = "Environment"
  description      = "Deployment environment classification"

  validator {
    validator_type = "ENUM"
    values         = var.environment_values
  }
}

# Application tag for resource grouping
resource "oci_identity_tag" "application" {
  tag_namespace_id = oci_identity_tag_namespace.operations.id
  name             = "Application"
  description      = "Application or service name"

  validator {
    validator_type = "ENUM"
    values         = var.application_values
  }
}

# Tag defaults for automatic tagging
resource "oci_identity_tag_default" "arcs_prod_cost_center" {
  compartment_id    = local.compartment_map["ARCS-Prod"]
  tag_definition_id = oci_identity_tag.cost_center.id
  value             = "Finance"
  is_required       = true
}

resource "oci_identity_tag_default" "arcs_prod_environment" {
  compartment_id    = local.compartment_map["ARCS-Prod"]
  tag_definition_id = oci_identity_tag.environment.id
  value             = "Production"
  is_required       = true
}

resource "oci_identity_tag_default" "arcs_test_cost_center" {
  compartment_id    = local.compartment_map["ARCS-Test"]
  tag_definition_id = oci_identity_tag.cost_center.id
  value             = "Finance"
  is_required       = true
}

resource "oci_identity_tag_default" "arcs_test_environment" {
  compartment_id    = local.compartment_map["ARCS-Test"]
  tag_definition_id = oci_identity_tag.environment.id
  value             = "Test"
  is_required       = true
}