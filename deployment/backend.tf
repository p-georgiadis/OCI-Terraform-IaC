# Terraform Backend Configuration - OCI Native Backend
#
# This uses OCI's native Terraform backend (recommended by Oracle)
# No AWS credentials needed - uses your OCI CLI configuration
#
# Requirements:
# - Terraform >= 1.12.0
# - OCI CLI configured (~/.oci/config)
#
# Team Collaboration:
# - State stored in OCI Object Storage
# - Automatic state locking
# - All team members use their own OCI credentials
# - Access controlled via IAM policies
#
# Authentication:
# - Uses OCI CLI config by default (~/.oci/config)
# - Or uses environment variables (OCI_TENANCY_OCID, etc.)
#
# State Location:
# - Bucket: terraform-state
# - Object: deployment.tfstate

terraform {
  required_version = ">= 1.12.0"
  
  backend "oci" {
    bucket    = "terraform-state"
    key       = "deployment.tfstate"
    namespace = "frjpqj7r0mi3"
    region    = "eu-frankfurt-1"
    
    # Authentication via OCI CLI config
    # No additional credentials needed!
    # Team members use their own ~/.oci/config
  }
}