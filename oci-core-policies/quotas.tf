# Quota policies to prevent unauthorized resource creation

# SaaS compartments - block EVERYTHING except EPM services
resource "oci_limits_quota" "saas_restrictions" {
  compartment_id = var.tenancy_ocid
  name           = "saas-compartment-restrictions"
  description    = "Prevent all IaaS/PaaS resource creation in SaaS compartments"
  
  statements = [
    # Compute and related
    "zero compute-core quotas in compartment SaaS-Root",
    "zero compute-memory quotas in compartment SaaS-Root",
    "zero compute quotas in compartment SaaS-Root",
    "zero compute-management quotas in compartment SaaS-Root",
    "zero auto-scaling quotas in compartment SaaS-Root",
    "zero container-engine quotas in compartment SaaS-Root",
    "zero cluster-placement-groups quotas in compartment SaaS-Root",
    
    # Storage
    "zero block-storage quotas in compartment SaaS-Root",
    "zero object-storage quotas in compartment SaaS-Root",
    "zero filesystem quotas in compartment SaaS-Root",
    "zero lustrefilestorage quotas in compartment SaaS-Root",
    
    # Database
    "zero database quotas in compartment SaaS-Root",
    "zero nosql quotas in compartment SaaS-Root",
    "zero postgresql quotas in compartment SaaS-Root",
    "zero database-migration quotas in compartment SaaS-Root",
    
    # Networking
    "zero vcn quotas in compartment SaaS-Root",
    "zero load-balancer quotas in compartment SaaS-Root",
    "zero network-load-balancer-api quotas in compartment SaaS-Root",
    "zero network-firewall quotas in compartment SaaS-Root",
    "zero fast-connect quotas in compartment SaaS-Root",
    "zero vpn quotas in compartment SaaS-Root",
    "zero dns quotas in compartment SaaS-Root",
    "zero network-path-analyzer quotas in compartment SaaS-Root",
    
    # AI/ML Services
    "zero ai-anomaly-detection quotas in compartment SaaS-Root",
    "zero ai-document quotas in compartment SaaS-Root",
    "zero ai-forecasting quotas in compartment SaaS-Root",
    "zero ai-vision quotas in compartment SaaS-Root",
    "zero ai-language quotas in compartment SaaS-Root",
    "zero ai-speech quotas in compartment SaaS-Root",
    "zero data-science quotas in compartment SaaS-Root",
    "zero data-labeling quotas in compartment SaaS-Root",
    
    # Analytics and Data
    "zero analytics quotas in compartment SaaS-Root",
    "zero data-catalog quotas in compartment SaaS-Root",
    "zero data-flow quotas in compartment SaaS-Root",
    "zero data-integration quotas in compartment SaaS-Root",
    "zero big-data quotas in compartment SaaS-Root",
    "zero streaming quotas in compartment SaaS-Root",
    "zero oci-kafka quotas in compartment SaaS-Root",
    "zero goldengate quotas in compartment SaaS-Root",
    
    # Application Services
    "zero api-gateway quotas in compartment SaaS-Root",
    "zero faas quotas in compartment SaaS-Root",
    "zero integration quotas in compartment SaaS-Root",
    "zero process-automation quotas in compartment SaaS-Root",
    "zero digital-assistant quotas in compartment SaaS-Root",
    "zero visualbuilder quotas in compartment SaaS-Root",
    
    # Management and Monitoring
    "zero operations-insights quotas in compartment SaaS-Root",
    "zero logging quotas in compartment SaaS-Root",
    "zero management-agent quotas in compartment SaaS-Root",
    "zero stack-monitoring quotas in compartment SaaS-Root",
    "zero apm quotas in compartment SaaS-Root",
    "zero resource-manager quotas in compartment SaaS-Root",
    
    # Security (not needed in SaaS compartments)
    "zero cloudguard quotas in compartment SaaS-Root",
    "zero vulnerability-scanning quotas in compartment SaaS-Root",
    "zero waf quotas in compartment SaaS-Root",
    "zero waas quotas in compartment SaaS-Root",
    "zero kms quotas in compartment SaaS-Root",
    
    # Other services
    "zero devops quotas in compartment SaaS-Root",
    "zero email-delivery quotas in compartment SaaS-Root",
    "zero notifications quotas in compartment SaaS-Root",
    "zero events quotas in compartment SaaS-Root",
    "zero service-connector-hub quotas in compartment SaaS-Root",
    "zero queue quotas in compartment SaaS-Root",
    "zero blockchain quotas in compartment SaaS-Root",
    "zero redis quotas in compartment SaaS-Root",
  ]
}

# IaaS compartments - locked until approved
resource "oci_limits_quota" "iaas_restrictions" {
  compartment_id = var.tenancy_ocid
  name           = "iaas-compartment-restrictions"
  description    = "Prevent resource creation in IaaS compartments until approved for use"
  
  statements = [
    # Compute and related
    "zero compute-core quotas in compartment SaaS-Root",
    "zero compute-memory quotas in compartment SaaS-Root",
    "zero compute quotas in compartment SaaS-Root",
    "zero compute-management quotas in compartment SaaS-Root",
    "zero auto-scaling quotas in compartment SaaS-Root",
    "zero container-engine quotas in compartment SaaS-Root",
    "zero cluster-placement-groups quotas in compartment SaaS-Root",
    
    # Storage
    "zero block-storage quotas in compartment SaaS-Root",
    "zero object-storage quotas in compartment SaaS-Root",
    "zero filesystem quotas in compartment SaaS-Root",
    "zero lustrefilestorage quotas in compartment SaaS-Root",
    
    # Database
    "zero database quotas in compartment SaaS-Root",
    "zero nosql quotas in compartment SaaS-Root",
    "zero postgresql quotas in compartment SaaS-Root",
    "zero database-migration quotas in compartment SaaS-Root",
    
    # Networking
    "zero vcn quotas in compartment SaaS-Root",
    "zero load-balancer quotas in compartment SaaS-Root",
    "zero network-load-balancer-api quotas in compartment SaaS-Root",
    "zero network-firewall quotas in compartment SaaS-Root",
    "zero fast-connect quotas in compartment SaaS-Root",
    "zero vpn quotas in compartment SaaS-Root",
    "zero dns quotas in compartment SaaS-Root",
    "zero network-path-analyzer quotas in compartment SaaS-Root",
    
    # AI/ML Services
    "zero ai-anomaly-detection quotas in compartment SaaS-Root",
    "zero ai-document quotas in compartment SaaS-Root",
    "zero ai-forecasting quotas in compartment SaaS-Root",
    "zero ai-vision quotas in compartment SaaS-Root",
    "zero ai-language quotas in compartment SaaS-Root",
    "zero ai-speech quotas in compartment SaaS-Root",
    "zero data-science quotas in compartment SaaS-Root",
    "zero data-labeling quotas in compartment SaaS-Root",
    
    # Analytics and Data
    "zero analytics quotas in compartment SaaS-Root",
    "zero data-catalog quotas in compartment SaaS-Root",
    "zero data-flow quotas in compartment SaaS-Root",
    "zero data-integration quotas in compartment SaaS-Root",
    "zero big-data quotas in compartment SaaS-Root",
    "zero streaming quotas in compartment SaaS-Root",
    "zero oci-kafka quotas in compartment SaaS-Root",
    "zero goldengate quotas in compartment SaaS-Root",
    
    # Application Services
    "zero api-gateway quotas in compartment SaaS-Root",
    "zero faas quotas in compartment SaaS-Root",
    "zero integration quotas in compartment SaaS-Root",
    "zero process-automation quotas in compartment SaaS-Root",
    "zero digital-assistant quotas in compartment SaaS-Root",
    "zero visualbuilder quotas in compartment SaaS-Root",
    
    # Management and Monitoring
    "zero operations-insights quotas in compartment SaaS-Root",
    "zero logging quotas in compartment SaaS-Root",
    "zero management-agent quotas in compartment SaaS-Root",
    "zero stack-monitoring quotas in compartment SaaS-Root",
    "zero apm quotas in compartment SaaS-Root",
    "zero resource-manager quotas in compartment SaaS-Root",
    
    # Security (not needed in SaaS compartments)
    "zero cloudguard quotas in compartment SaaS-Root",
    "zero vulnerability-scanning quotas in compartment SaaS-Root",
    "zero waf quotas in compartment SaaS-Root",
    "zero waas quotas in compartment SaaS-Root",
    "zero kms quotas in compartment SaaS-Root",
    
    # Other services
    "zero devops quotas in compartment SaaS-Root",
    "zero email-delivery quotas in compartment SaaS-Root",
    "zero notifications quotas in compartment SaaS-Root",
    "zero events quotas in compartment SaaS-Root",
    "zero service-connector-hub quotas in compartment SaaS-Root",
    "zero queue quotas in compartment SaaS-Root",
    "zero blockchain quotas in compartment SaaS-Root",
    "zero redis quotas in compartment SaaS-Root",
  ]
}

# Shared services - only security services allowed
resource "oci_limits_quota" "shared_services_restrictions" {
  compartment_id = var.tenancy_ocid
  name           = "shared-services-restrictions"
  description    = "Only allow security services in shared-services compartment"
  
  statements = [
    # Block all compute and databases
    "zero compute-core quotas in compartment shared-services",
    "zero compute-memory quotas in compartment shared-services",
    "zero compute quotas in compartment shared-services",
    "zero database quotas in compartment shared-services",
    "zero block-storage quotas in compartment shared-services",
    "zero object-storage quotas in compartment shared-services",
    
    # Block most networking except minimal for Service Connector
    "zero load-balancer quotas in compartment shared-services",
    "zero network-load-balancer-api quotas in compartment shared-services",
    "zero fast-connect quotas in compartment shared-services",
    "zero vpn quotas in compartment shared-services",
    
    # Block all application services
    "zero api-gateway quotas in compartment shared-services",
    "zero faas quotas in compartment shared-services",
    "zero container-engine quotas in compartment shared-services",
    
    # Allow one VCN for Service Connector Hub
    "set vcn quota vcn-count to 1 in compartment shared-services",
    
    # Note: Cloud Guard, logging, monitoring don't have quotas - they'll be allowed
  ]
}