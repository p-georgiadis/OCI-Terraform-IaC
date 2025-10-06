# OCI Authentication
variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "Must be a valid tenancy OCID."
  }
}

variable "user_ocid" {
  description = "OCI user OCID"
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

# Group names
variable "iam_admin_group" {
  description = "Name of the IAM administrators group"
  type        = string
  default     = "IAM_OCI_SECUREROLE_IAMAdmins"
}

variable "sec_admin_group" {
  description = "Name of the security administrators group"
  type        = string
  default     = "IAM_OCI_SECUREROLE_SECAdmins"
}

# Policy toggles
variable "deploy_arcs_policies" {
  description = "Deploy ARCS-specific policies"
  type        = bool
  default     = true
}

variable "deploy_iaas_policies" {
  description = "Deploy IaaS policies (for future use)"
  type        = bool
  default     = false
}

# Tag values
variable "cost_center_values" {
  description = "Valid values for CostCenter tag"
  type        = list(string)
  default     = ["Finance", "IT", "Operations", "Other"]
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