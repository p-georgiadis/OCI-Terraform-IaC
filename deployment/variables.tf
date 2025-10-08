# OCI Authentication Variables (no defaults - must be provided)
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
}

variable "fingerprint" {
  description = "API key fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
}

variable "private_key_password" {
  description = "Private key password if encrypted"
  type        = string
  default     = ""
  sensitive   = true
}

variable "region" {
  description = "OCI region"
  type        = string
}

# Compartment Configuration - defaults match requirements
variable "shared_services_compartment_name" {
  description = "Name for shared services compartment"
  type        = string
  default     = "shared-services"
}

variable "shared_services_description" {
  description = "Description for shared services compartment"
  type        = string
  default     = "Compartment for shared OCI services including Cloud Guard, logging, and monitoring"
}

variable "iaas_compartment_name" {
  description = "Name for IaaS root compartment"
  type        = string
  default     = "IaaS-Root"
}

variable "enable_compartment_delete" {
  description = "Enable deletion of compartments (for dev/test)"
  type        = bool
  default     = true # Can be changed to false for production
}

# IaaS Configuration - defaults for current state
variable "iaas_create_environments" {
  description = "Create prod/non-prod environments in IaaS"
  type        = bool
  default     = false # Not needed yet
}

# Policy Configuration - defaults for current deployment
variable "enable_arcs_policies" {
  description = "Deploy ARCS-specific policies"
  type        = bool
  default     = true # ARCS is active
}

variable "enable_iaas_policies" {
  description = "Deploy IaaS policies (NetworkAdmins, DBAdmins groups)"
  type        = bool
  default     = false # These groups don't exist yet
}

# Tag Configuration - sensible defaults for Hanover
variable "cost_center_values" {
  description = "Valid values for CostCenter tag"
  type        = list(string)
  default     = ["Finance", "IT", "Operations", "Shared"]
}

variable "environment_values" {
  description = "Valid values for Environment tag"
  type        = list(string)
  default     = ["Production", "Test", "Development", "Staging", "Parked"]
}

variable "application_values" {
  description = "Valid values for Application tag"
  type        = list(string)
  default     = ["ARCS", "Planning", "EDMCS", "Freeform", "Infrastructure", "Security"]
}

# Security Module Configuration
variable "security_notification_emails" {
  description = "List of email addresses to receive security notifications"
  type        = list(string)
  default     = []
}

variable "notification_topic_name" {
  description = "Name for the security notification topic"
  type        = string
  default     = "security-notifications"
}

variable "cloud_guard_target_name" {
  description = "Display name for the Cloud Guard target"
  type        = string
  default     = "root-compartment-target"
}

variable "cloud_guard_self_manage_resources" {
  description = "Allow Cloud Guard to create and manage resources for remediation"
  type        = bool
  default     = false
}
