resource "oci_identity_group" "groups" {
  for_each = local.groups

  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description = coalesce(
    try(each.value.description, ""),
    "${each.value.name} group"
  )

  freeform_tags = merge(
    var.default_tags,
    try(each.value.freeform_tags, {})
  )

  defined_tags = try(each.value.defined_tags, null)
}