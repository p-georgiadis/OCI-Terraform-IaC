variable "tenancy_ocid" {
  type        = string
  description = "Root tenancy OCID"
}

variable "compartment_hierarchy" {
  description = "Nested map describing compartments"
  type        = map(any)
}