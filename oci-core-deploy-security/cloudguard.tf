# Cloud Guard Configuration
# Based on Oracle CIS Landing Zone best practices

# Data sources to find Oracle-managed recipes
# These exist automatically when Cloud Guard is enabled
data "oci_cloud_guard_detector_recipes" "configuration" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  
  # Filter for Oracle-managed configuration detector
  filter {
    name   = "owner"
    values = ["ORACLE"]
  }
  filter {
    name   = "detector"
    values = ["IAAS_CONFIGURATION_DETECTOR"]
  }
}

data "oci_cloud_guard_detector_recipes" "activity" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "owner"
    values = ["ORACLE"]
  }
  filter {
    name   = "detector"
    values = ["IAAS_ACTIVITY_DETECTOR"]
  }
}

data "oci_cloud_guard_detector_recipes" "threat" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "owner"
    values = ["ORACLE"]
  }
  filter {
    name   = "detector"
    values = ["IAAS_THREAT_DETECTOR"]
  }
}

data "oci_cloud_guard_responder_recipes" "responder" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  
  filter {
    name   = "owner"
    values = ["ORACLE"]
  }
}

# Clone Oracle-managed recipes (recommended for customization)
# This creates your own copies that you can modify
resource "oci_cloud_guard_detector_recipe" "configuration_cloned" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  display_name   = "hanover-configuration-detector-recipe"
  description    = "Hanover configuration detector recipe (cloned from Oracle managed recipe)"
  
  # Clone from Oracle-managed recipe
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.configuration[0].detector_recipe_collection[0].items[0].id
  
  freeform_tags = merge(
    var.freeform_tags,
    {
      "Module" = "oci-core-deploy-security"
      "Type"   = "Configuration-Detector"
    }
  )
}

resource "oci_cloud_guard_detector_recipe" "activity_cloned" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  display_name   = "hanover-activity-detector-recipe"
  description    = "Hanover activity detector recipe (cloned from Oracle managed recipe)"
  
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.activity[0].detector_recipe_collection[0].items[0].id
  
  freeform_tags = merge(
    var.freeform_tags,
    {
      "Module" = "oci-core-deploy-security"
      "Type"   = "Activity-Detector"
    }
  )
}

resource "oci_cloud_guard_detector_recipe" "threat_cloned" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  display_name   = "hanover-threat-detector-recipe"
  description    = "Hanover threat detector recipe (cloned from Oracle managed recipe)"
  
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.threat[0].detector_recipe_collection[0].items[0].id
  
  freeform_tags = merge(
    var.freeform_tags,
    {
      "Module" = "oci-core-deploy-security"
      "Type"   = "Threat-Detector"
    }
  )
}

resource "oci_cloud_guard_responder_recipe" "responder_cloned" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  display_name   = "hanover-responder-recipe"
  description    = "Hanover responder recipe (cloned from Oracle managed recipe)"
  
  source_responder_recipe_id = data.oci_cloud_guard_responder_recipes.responder[0].responder_recipe_collection[0].items[0].id
  
  freeform_tags = merge(
    var.freeform_tags,
    {
      "Module" = "oci-core-deploy-security"
      "Type"   = "Responder"
    }
  )
}

# Enable Cloud Guard
resource "oci_cloud_guard_cloud_guard_configuration" "cloud_guard_config" {
  count = var.enable_cloud_guard ? 1 : 0

  compartment_id        = var.tenancy_ocid
  reporting_region      = var.region
  status                = "ENABLED"
  self_manage_resources = var.cloud_guard_self_manage_resources
  
  depends_on = [oci_identity_policy.cloud_guard_service_policy]
}

# Create Cloud Guard Target using cloned recipes
resource "oci_cloud_guard_target" "root_target" {
  count = var.enable_cloud_guard ? 1 : 0

  compartment_id       = var.tenancy_ocid
  display_name         = var.cloud_guard_target_name
  target_resource_id   = var.tenancy_ocid
  target_resource_type = "COMPARTMENT"
  description          = "Cloud Guard target for root compartment - monitors entire tenancy for CIS compliance"

  # Use cloned detector recipes
  target_detector_recipes {
    detector_recipe_id = oci_cloud_guard_detector_recipe.configuration_cloned[0].id
  }

  target_detector_recipes {
    detector_recipe_id = oci_cloud_guard_detector_recipe.activity_cloned[0].id
  }

  target_detector_recipes {
    detector_recipe_id = oci_cloud_guard_detector_recipe.threat_cloned[0].id
  }

  # Use cloned responder recipe
  target_responder_recipes {
    responder_recipe_id = oci_cloud_guard_responder_recipe.responder_cloned[0].id
  }

  depends_on = [
    oci_cloud_guard_cloud_guard_configuration.cloud_guard_config,
    oci_cloud_guard_detector_recipe.configuration_cloned,
    oci_cloud_guard_detector_recipe.activity_cloned,
    oci_cloud_guard_detector_recipe.threat_cloned,
    oci_cloud_guard_responder_recipe.responder_cloned
  ]

  freeform_tags = var.freeform_tags
}