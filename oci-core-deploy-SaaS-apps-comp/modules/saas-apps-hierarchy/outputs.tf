output "compartment_ids" {
  description = "Map of compartment names to OCIDs"
  value = merge(
    { for k, v in oci_identity_compartment.root_comps : k => v.id },
    { for k, v in oci_identity_compartment.child_comps : v.name => v.id },
    { for k, v in oci_identity_compartment.grandchild_comps : v.name => v.id }
  )
}
