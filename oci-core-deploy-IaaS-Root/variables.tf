# variables.tf - Complete file for IaaS-Root module

# Compartment Configuration
variable "compartment_name" {
  description = "Name of the IaaS root compartment"
  type        = string
  default     = "IaaS-Root"
}

variable "compartment_description" {
  description = "Description of the IaaS root compartment"
  type        = string
  default     = "Root compartment for infrastructure resources (future use) - CIS compliant structure"
}

variable "enable_delete" {
  description = "Enable compartment deletion"
  type        = bool
  default     = true
}

# Optional Sub-compartment Configuration
variable "create_environment_separation" {
  description = "Create prod/non-prod separation under Applications"
  type        = bool
  default     = false  # Can enable later when needed
}

variable "application_environments" {
  description = "Environment compartments under Applications"
  type = map(object({
    description = string
    purpose     = string
  }))
  default = {
    "Prod" = {
      description = "Production application workloads"
      purpose     = "Production-Apps"
    }
    "Non-Prod" = {
      description = "Development and test application workloads"
      purpose     = "Non-Production-Apps"
    }
  }
}

# Tagging
variable "default_tags" {
  description = "Default tags for all compartments"
  type        = map(string)
  default = {
    ManagedBy    = "Terraform"
    Purpose      = "IaaS-Infrastructure"
    CISCompliant = "true"
  }
}

variable "freeform_tags" {
  description = "Additional freeform tags"
  type        = map(string)
  default     = {}
}

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