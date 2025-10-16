# Hanover OCI Infrastructure Deployment
# Centralized deployment of all infrastructure modules

# 1. Deploy Groups (must be first)
module "groups" {
  source = "../oci-core-deploy-groups"

  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region

  use_csv = true # Use the CSV file for groups
}

# 2. Deploy Shared Services Compartment
module "shared_services" {
  source = "../oci-core-deploy-shared-services"

  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region

  compartment_name        = var.shared_services_compartment_name
  compartment_description = var.shared_services_description
  enable_delete           = var.enable_compartment_delete
}

# 3. Deploy SaaS Compartments
module "saas_compartments" {
  source = "../oci-core-deploy-SaaS-apps-comp"

  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region
}

# 4. Deploy IaaS Compartments
module "iaas_compartments" {
  source = "../oci-core-deploy-IaaS-Root"

  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region

  compartment_name              = var.iaas_compartment_name
  create_environment_separation = var.iaas_create_environments
}

# 5. Deploy Security Services (Cloud Guard, Monitoring, Notifications)
module "security" {
  source = "../oci-core-deploy-security"

  depends_on = [
    module.shared_services
  ]

  # Tenancy OCID and region (needed for Cloud Guard)
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  # Shared Services Compartment for notifications
  shared_services_compartment_id = module.shared_services.compartment_id

  # Security notification emails
  security_notification_emails = var.security_notification_emails

  # Cloud Guard configuration
  enable_cloud_guard                = var.enable_cloud_guard
  notification_topic_name           = var.notification_topic_name
  cloud_guard_target_name           = var.cloud_guard_target_name
  cloud_guard_self_manage_resources = var.cloud_guard_self_manage_resources
}

# 6. Deploy Policies (must be last)
module "policies" {
  source = "../oci-core-policies"

  depends_on = [
    module.groups,
    module.shared_services,
    module.saas_compartments,
    module.iaas_compartments,
    module.security
  ]

  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region

  # Policy controls
  deploy_arcs_policies = var.enable_arcs_policies
  deploy_iaas_policies = var.enable_iaas_policies


  # Tag values
  cost_center_values = var.cost_center_values
  environment_values = var.environment_values
  application_values = var.application_values
}