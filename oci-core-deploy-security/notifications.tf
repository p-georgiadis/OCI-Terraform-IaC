# Oracle Notification Service (ONS) Configuration
# CIS Recommendation 4.2: Create notification topic and subscription

# Create notification topic for security alerts
resource "oci_ons_notification_topic" "security_topic" {
  compartment_id = var.shared_services_compartment_id
  name           = var.notification_topic_name
  description    = "Security and compliance notifications for CIS monitoring"

  freeform_tags = var.freeform_tags
}

# Create email subscriptions for security team
resource "oci_ons_subscription" "security_email_subscriptions" {
  for_each = toset(var.security_notification_emails)

  compartment_id = var.shared_services_compartment_id
  topic_id       = oci_ons_notification_topic.security_topic.id
  protocol       = "EMAIL"
  endpoint       = each.value

  freeform_tags = var.freeform_tags
}
