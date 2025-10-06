locals {
  # Flatten compartment structure for easier processing
  all_compartments = merge(
    { for k, v in oci_identity_compartment.root_comps : v.name => v },
    { for k, v in oci_identity_compartment.child_comps : v.name => v },
    { for k, v in oci_identity_compartment.grandchild_comps : v.name => v }
  )

  # Safe compartment name to ID mapping
  compartment_name_to_id = {
    for name, comp in local.all_compartments : name => comp.id
  }
}
