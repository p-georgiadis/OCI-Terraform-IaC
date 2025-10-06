variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "Must be a valid tenancy OCID."
  }
}

variable "compartment_name" {
  description = "Name of the shared services compartment"
  type        = string
  default     = "shared-services"
}

variable "compartment_description" {
  description = "Description of the shared services compartment"
  type        = string
  default     = "Compartment for shared OCI services including Cloud Guard, logging, and monitoring"
}

variable "enable_delete" {
  description = "Enable compartment deletion (for dev/test environments)"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags for the compartment"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Purpose     = "Shared-Services"
    Environment = "Production"
  }
}

variable "freeform_tags" {
  description = "Additional freeform tags"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for the compartment"
  type        = map(string)
  default     = null
}

# Auth variables
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