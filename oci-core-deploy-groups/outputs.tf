output "group_ids" {
  description = "Map of group names to OCIDs"
  value       = { for k, v in oci_identity_group.groups : v.name => v.id }
}

output "group_names" {
  description = "List of created group names"
  value       = [for g in oci_identity_group.groups : g.name]
}

output "groups_by_owner" {
  description = "Groups organized by owner tag"
  value = {
    for owner in distinct([for g in oci_identity_group.groups : try(g.freeform_tags["Owner"], "Unknown")]) :
    owner => [
      for g in oci_identity_group.groups : g.name
      if try(g.freeform_tags["Owner"], "Unknown") == owner
    ]
  }
}