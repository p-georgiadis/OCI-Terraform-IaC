# Event Rules for Security Monitoring
# CIS Recommendations 4.3-4.12, 4.15: Configure event notifications

# CIS 4.3: Identity Provider changes
resource "oci_events_rule" "identity_provider_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.3-identity-provider-changes"
  description    = "CIS 4.3: Alert on Identity Provider changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.identitycontrolplane.createidentityprovider",
      "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
      "com.oraclecloud.identitycontrolplane.updateidentityprovider"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.4: IdP Group Mapping changes
resource "oci_events_rule" "idp_group_mapping_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.4-idp-group-mapping-changes"
  description    = "CIS 4.4: Alert on IdP Group Mapping changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.identitycontrolplane.createidpgroupmapping",
      "com.oraclecloud.identitycontrolplane.deleteidpgroupmapping",
      "com.oraclecloud.identitycontrolplane.updateidpgroupmapping"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.5: IAM Group changes
resource "oci_events_rule" "iam_group_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.5-iam-group-changes"
  description    = "CIS 4.5: Alert on IAM Group changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.identitycontrolplane.creategroup",
      "com.oraclecloud.identitycontrolplane.deletegroup",
      "com.oraclecloud.identitycontrolplane.updategroup"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.6: IAM Policy changes
resource "oci_events_rule" "iam_policy_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.6-iam-policy-changes"
  description    = "CIS 4.6: Alert on IAM Policy changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.identitycontrolplane.createpolicy",
      "com.oraclecloud.identitycontrolplane.deletepolicy",
      "com.oraclecloud.identitycontrolplane.updatepolicy"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.7: User changes
resource "oci_events_rule" "user_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.7-user-changes"
  description    = "CIS 4.7: Alert on User changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.identitycontrolplane.createuser",
      "com.oraclecloud.identitycontrolplane.deleteuser",
      "com.oraclecloud.identitycontrolplane.updateuser",
      "com.oraclecloud.identitycontrolplane.updateusercapabilities",
      "com.oraclecloud.identitycontrolplane.updateuserstate"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.8: VCN changes
resource "oci_events_rule" "vcn_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.8-vcn-changes"
  description    = "CIS 4.8: Alert on VCN changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.virtualnetwork.createvcn",
      "com.oraclecloud.virtualnetwork.deletevcn",
      "com.oraclecloud.virtualnetwork.updatevcn"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.9: Route Table changes
resource "oci_events_rule" "route_table_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.9-route-table-changes"
  description    = "CIS 4.9: Alert on Route Table changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.virtualnetwork.changeroutetablecompartment",
      "com.oraclecloud.virtualnetwork.createroutetable",
      "com.oraclecloud.virtualnetwork.deleteroutetable",
      "com.oraclecloud.virtualnetwork.updateroutetable"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.10: Security List changes
resource "oci_events_rule" "security_list_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.10-security-list-changes"
  description    = "CIS 4.10: Alert on Security List changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
      "com.oraclecloud.virtualnetwork.createsecuritylist",
      "com.oraclecloud.virtualnetwork.deletesecuritylist",
      "com.oraclecloud.virtualnetwork.updatesecuritylist"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.11: Network Security Group changes
resource "oci_events_rule" "nsg_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.11-nsg-changes"
  description    = "CIS 4.11: Alert on Network Security Group changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
      "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
      "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
      "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.12: Network Gateway changes
resource "oci_events_rule" "network_gateway_changes" {
  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.12-network-gateway-changes"
  description    = "CIS 4.12: Alert on Network Gateway changes"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.virtualnetwork.createdrg",
      "com.oraclecloud.virtualnetwork.deletedrg",
      "com.oraclecloud.virtualnetwork.updatedrg",
      "com.oraclecloud.virtualnetwork.createdrgattachment",
      "com.oraclecloud.virtualnetwork.deletedrgattachment",
      "com.oraclecloud.virtualnetwork.updatedrgattachment",
      "com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment",
      "com.oraclecloud.virtualnetwork.createinternetgateway",
      "com.oraclecloud.virtualnetwork.deleteinternetgateway",
      "com.oraclecloud.virtualnetwork.updateinternetgateway",
      "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
      "com.oraclecloud.virtualnetwork.createlocalpeeringgateway",
      "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway.end",
      "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
      "com.oraclecloud.natgateway.changenatgatewaycompartment",
      "com.oraclecloud.natgateway.createnatgateway",
      "com.oraclecloud.natgateway.deletenatgateway",
      "com.oraclecloud.natgateway.updatenatgateway",
      "com.oraclecloud.servicegateway.attachserviceid",
      "com.oraclecloud.servicegateway.changeservicegatewaycompartment",
      "com.oraclecloud.servicegateway.createservicegateway",
      "com.oraclecloud.servicegateway.deleteservicegateway.end",
      "com.oraclecloud.servicegateway.detachserviceid",
      "com.oraclecloud.servicegateway.updateservicegateway"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}

# CIS 4.15: Cloud Guard Problems (only when Cloud Guard is enabled)
resource "oci_events_rule" "cloud_guard_problems" {
  count = var.enable_cloud_guard ? 1 : 0

  compartment_id = var.tenancy_ocid
  display_name   = "cis-4.15-cloud-guard-problems"
  description    = "CIS 4.15: Alert on Cloud Guard Problems"
  is_enabled     = true

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.cloudguard.problemdetected",
      "com.oraclecloud.cloudguard.problemdismissed",
      "com.oraclecloud.cloudguard.problemremediated"
    ]
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.security_topic.id
    }
  }

  freeform_tags = var.freeform_tags
}
