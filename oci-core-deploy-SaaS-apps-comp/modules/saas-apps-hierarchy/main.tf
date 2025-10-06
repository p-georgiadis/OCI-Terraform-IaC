# Root compartments
resource "oci_identity_compartment" "root_comps" {
  for_each = var.compartment_hierarchy

  name           = each.key
  description    = lookup(each.value, "description", each.key)
  compartment_id = var.tenancy_ocid
  enable_delete  = true

  freeform_tags = lookup(each.value, "tags", {
    "ManagedBy" = "Terraform"
    "Purpose"   = "SaaS-Applications"
  })
}

# First-level children
resource "oci_identity_compartment" "child_comps" {
  for_each = merge([
    for cname, cdef in var.compartment_hierarchy : {
      for subname, subdef in lookup(cdef, "children", {}) :
      "${cname}/${subname}" => {
        name        = subname
        description = lookup(subdef, "description", subname)
        parent      = cname
        tags        = lookup(subdef, "tags", {})
      }
    }
  ]...)

  name           = each.value.name
  description    = each.value.description
  compartment_id = oci_identity_compartment.root_comps[each.value.parent].id
  enable_delete  = true

  freeform_tags = merge(
    { "ManagedBy" = "Terraform" },
    each.value.tags
  )
}

# Second-level children (grandchildren)
resource "oci_identity_compartment" "grandchild_comps" {
  for_each = merge([
    for path, cdef in merge([
      for cname, cdef in var.compartment_hierarchy : {
        for subname, subdef in lookup(cdef, "children", {}) :
        "${cname}/${subname}" => subdef
      }
      ]...) : {
      for gname, gdef in lookup(cdef, "children", {}) :
      "${path}/${gname}" => {
        name        = gname
        description = lookup(gdef, "description", gname)
        parent      = path
        tags        = lookup(gdef, "tags", {})
      }
    }
  ]...)

  name           = each.value.name
  description    = each.value.description
  compartment_id = oci_identity_compartment.child_comps[each.value.parent].id
  enable_delete  = true

  freeform_tags = merge(
    { "ManagedBy" = "Terraform" },
    each.value.tags
  )
}

# Wait for IAM propagation
resource "time_sleep" "wait_for_compartments" {
  depends_on = [
    oci_identity_compartment.root_comps,
    oci_identity_compartment.child_comps,
    oci_identity_compartment.grandchild_comps,
  ]
  create_duration = "60s" # Increased from 45s for better reliability
}
