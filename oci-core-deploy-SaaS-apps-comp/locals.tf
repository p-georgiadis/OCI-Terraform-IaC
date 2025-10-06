locals {
  # Common tags for all resources
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Project"     = "ICF2511"
    "Environment" = "Production"
  }

  # List of resources to set zero quota
  quota_resources = [
    "compute-core-count",
    "database-count",
    "vcn-count",
    "volume-count",
    "autonomous-database-count",
    "lb-count",
    "instance-pool-count",
    "cluster-count"
  ]

  # Environment mapping
  environment_map = {
    "ARCS-Prod" = "Production"
    "ARCS-Test" = "Test"
    "Planning"  = "Parked"
    "EDMCS"     = "Parked"
    "Freeform"  = "Parked"
  }
}
