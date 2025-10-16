# Tenancy OCID (needed for event rules and Cloud Guard)
variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy"
}

# Region (needed for Cloud Guard reporting region)
variable "region" {
  type        = string
  description = "The OCI region for Cloud Guard reporting"
}

# Enable/Disable Cloud Guard (set to false for free tier)
variable "enable_cloud_guard" {
  type        = bool
  description = "Enable Cloud Guard (requires paid subscription, set to false for free tier)"
  default     = true
}

# Shared Services Compartment
variable "shared_services_compartment_id" {
  type        = string
  description = "OCID of the shared-services compartment where notifications will be created"
}

# Cloud Guard Configuration
variable "cloud_guard_target_name" {
  type        = string
  description = "Display name for the Cloud Guard target"
  default     = "root-compartment-target"
}

variable "cloud_guard_self_manage_resources" {
  type        = bool
  description = "Allow Cloud Guard to create and manage resources for remediation"
  default     = false
}

# Optional: Specify custom detector/responder recipe IDs (leave empty to use Oracle-managed)
variable "cloud_guard_configuration_detector_recipe_id" {
  type        = string
  description = "OCID of custom configuration detector recipe (optional)"
  default     = ""
}

variable "cloud_guard_activity_detector_recipe_id" {
  type        = string
  description = "OCID of custom activity detector recipe (optional)"
  default     = ""
}

variable "cloud_guard_threat_detector_recipe_id" {
  type        = string
  description = "OCID of custom threat detector recipe (optional)"
  default     = ""
}

variable "cloud_guard_responder_recipe_id" {
  type        = string
  description = "OCID of custom responder recipe (optional)"
  default     = ""
}

# Notification Configuration
variable "notification_topic_name" {
  type        = string
  description = "Name for the security notification topic"
  default     = "security-notifications"
}

variable "security_notification_emails" {
  type        = list(string)
  description = "List of email addresses to receive security notifications"
  default     = []
}

# Tags
variable "freeform_tags" {
  type        = map(string)
  description = "Freeform tags to apply to all resources"
  default = {
    Purpose = "Security-Compliance"
    Module  = "oci-core-deploy-security"
  }
}
