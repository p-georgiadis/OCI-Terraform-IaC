# Description: Variables for the deploy-groups module
variable "use_csv" {
  description = "Use CSV file for group definitions"
  type        = bool
  default     = true
}

variable "iam_groups" {
  description = "Map of IAM group definitions"
  type = map(object({
    name          = string
    description   = optional(string)
    freeform_tags = optional(map(string))
    defined_tags  = optional(map(string))
  }))
  default = {}
}

variable "default_tags" {
  description = "Default tags applied to all groups"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Module    = "oci-core-deploy-groups"
  }
}

# New OCI provider authentication variables
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
  description = "Path to the OCI API private key file"
  type        = string
}

variable "private_key_password" {
  description = "Private key password (if your key is encrypted)"
  type        = string
  default     = ""
}

variable "region" {
  description = "OCI region"
  type        = string
}
