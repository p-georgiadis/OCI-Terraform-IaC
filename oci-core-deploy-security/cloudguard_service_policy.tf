# Cloud Guard Service Policy
# CRITICAL: This policy MUST exist before Cloud Guard can be enabled
# It grants the Cloud Guard SERVICE permission to monitor resources

resource "oci_identity_policy" "cloud_guard_service_policy" {
  count = var.enable_cloud_guard ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "CloudGuardPolicies"
  description    = "Service policy to allow Cloud Guard to manage and monitor resources in the tenancy"

  statements = [
    # Event Management
    "allow service cloudguard to manage cloudevents-rules in tenancy where target.rule.type='managed'",
    
    # Security Resources
    "allow service cloudguard to read vaults in tenancy",
    "allow service cloudguard to read keys in tenancy",
    
    # Core Resources
    "allow service cloudguard to read compartments in tenancy",
    "allow service cloudguard to read tenancies in tenancy",
    "allow service cloudguard to read audit-events in tenancy",
    
    # Compute Resources
    "allow service cloudguard to read compute-management-family in tenancy",
    "allow service cloudguard to read instance-family in tenancy",
    
    # Network Resources
    "allow service cloudguard to read virtual-network-family in tenancy",
    "allow service cloudguard to use network-security-groups in tenancy",
    
    # Storage Resources
    "allow service cloudguard to read volume-family in tenancy",
    "allow service cloudguard to read object-family in tenancy",
    
    # Database Resources
    "allow service cloudguard to read database-family in tenancy",
    "allow service cloudguard to read autonomous-database-family in tenancy",
    "allow service cloudguard to read data-safe-family in tenancy",
    
    # Load Balancers
    "allow service cloudguard to read load-balancers in tenancy",
    
    # IAM Resources
    "allow service cloudguard to read users in tenancy",
    "allow service cloudguard to read groups in tenancy",
    "allow service cloudguard to read policies in tenancy",
    "allow service cloudguard to read dynamic-groups in tenancy",
    "allow service cloudguard to read authentication-policies in tenancy",
    
    # Logging
    "allow service cloudguard to read log-groups in tenancy",
    
    # Workload Protection (Advanced Security)
    "Allow any-user to { WLP_BOM_READ } in tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent'}",
    "Allow any-user to { WLP_CONFIG_READ } in tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent'}",
    "Endorse any-user to { WLP_LOG_CREATE } in any-tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent' }",
    "Endorse any-user to { WLP_METRICS_CREATE } in any-tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent' }",
    "Endorse any-user to { WLP_ADHOC_QUERY_READ } in any-tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent' }",
    "Endorse any-user to { WLP_ADHOC_RESULTS_CREATE } in any-tenancy where all { request.principal.id = target.agent.id, request.principal.type = 'workloadprotectionagent'}",
  ]

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true after first successful deployment
  }
}