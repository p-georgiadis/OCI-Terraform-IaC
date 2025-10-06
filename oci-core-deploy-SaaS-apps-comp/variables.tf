variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.tenancy\\.", var.tenancy_ocid))
    error_message = "The tenancy_ocid must be a valid OCI tenancy OCID starting with 'ocid1.tenancy.'"
  }
}
variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.user\\.", var.user_ocid))
    error_message = "The user_ocid must be a valid OCI user OCID starting with 'ocid1.user.'"
  }
}
variable "region" {
  description = "OCI region"
  type        = string
  validation {
    condition = contains([
      "us-ashburn-1", "us-phoenix-1", "ca-toronto-1", "ca-montreal-1",
      "eu-frankfurt-1", "eu-amsterdam-1", "uk-london-1", "eu-zurich-1",
      "ap-mumbai-1", "ap-seoul-1", "ap-sydney-1", "ap-osaka-1", "ap-tokyo-1",
      "us-sanjose-1", "sa-saopaulo-1", "sa-vinhedo-1", "me-jeddah-1", "me-dubai-1"
    ], var.region)
    error_message = "Must be a valid OCI region identifier."
  }
}
variable "fingerprint" {
  description = "API key fingerprint"
  type        = string
  validation {
    condition     = can(regex("^[a-f0-9]{2}(:[a-f0-9]{2}){15}$", var.fingerprint))
    error_message = "Fingerprint must be in the format: aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
  }
}
variable "private_key_path" {
  description = "Path to private key file"
  type        = string
}
variable "private_key_password" {
  description = "Private key password (if your key is encrypted)"
  type        = string
  default     = ""
  sensitive   = true
}
variable "enable_quotas" {
  description = "Enable quota policies to prevent IaaS/PaaS creation"
  type        = bool
  default     = true
}
variable "enable_tagging" {
  description = "Enable automatic tagging with defaults"
  type        = bool
  default     = true
}
