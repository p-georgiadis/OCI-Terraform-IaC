# Cloud Guard Outputs
output "cloud_guard_config_status" {
  description = "Status of Cloud Guard configuration"
  value       = oci_cloud_guard_cloud_guard_configuration.cloud_guard_config.status
}

output "cloud_guard_target_id" {
  description = "OCID of the Cloud Guard target for root compartment"
  value       = oci_cloud_guard_target.root_target.id
}

output "cloud_guard_reporting_region" {
  description = "Reporting region for Cloud Guard"
  value       = oci_cloud_guard_cloud_guard_configuration.cloud_guard_config.reporting_region
}

# Notification Outputs
output "security_notification_topic_id" {
  description = "OCID of the security notification topic"
  value       = oci_ons_notification_topic.security_topic.id
}

output "security_notification_topic_name" {
  description = "Name of the security notification topic"
  value       = oci_ons_notification_topic.security_topic.name
}

output "security_email_subscriptions" {
  description = "Map of email subscriptions created"
  value = {
    for email, subscription in oci_ons_subscription.security_email_subscriptions :
    email => {
      id     = subscription.id
      state  = subscription.state
    }
  }
}

# Event Rules Outputs
output "event_rule_ids" {
  description = "Map of CIS recommendation to Event Rule OCID"
  value = {
    "4.3"  = oci_events_rule.identity_provider_changes.id
    "4.4"  = oci_events_rule.idp_group_mapping_changes.id
    "4.5"  = oci_events_rule.iam_group_changes.id
    "4.6"  = oci_events_rule.iam_policy_changes.id
    "4.7"  = oci_events_rule.user_changes.id
    "4.8"  = oci_events_rule.vcn_changes.id
    "4.9"  = oci_events_rule.route_table_changes.id
    "4.10" = oci_events_rule.security_list_changes.id
    "4.11" = oci_events_rule.nsg_changes.id
    "4.12" = oci_events_rule.network_gateway_changes.id
    "4.15" = oci_events_rule.cloud_guard_problems.id
  }
}

output "cis_compliance_summary" {
  description = "Summary of CIS recommendations addressed by this module"
  value = {
    cloud_guard_enabled = true
    notification_topic_created = true
    event_rules_created = 11
    recommendations_addressed = [
      "4.2 - Notification topic and subscription created",
      "4.3 - Identity Provider change notifications configured",
      "4.4 - IdP Group Mapping change notifications configured",
      "4.5 - IAM Group change notifications configured",
      "4.6 - IAM Policy change notifications configured",
      "4.7 - User change notifications configured",
      "4.8 - VCN change notifications configured",
      "4.9 - Route Table change notifications configured",
      "4.10 - Security List change notifications configured",
      "4.11 - Network Security Group change notifications configured",
      "4.12 - Network Gateway change notifications configured",
      "4.14 - Cloud Guard enabled in root compartment",
      "4.15 - Cloud Guard problem notifications configured"
    ]
  }
}
