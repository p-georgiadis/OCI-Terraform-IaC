module "saas_apps" {
  source = "./modules/saas-apps-hierarchy"

  tenancy_ocid = var.tenancy_ocid

  compartment_hierarchy = {
    "SaaS-Root" = {
      description = "Root compartment for all SaaS applications - EPM Suite"
      children = {
        "ARCS" = {
          description = "Account Reconciliation Cloud Service"
          children = {
            "ARCS-Prod" = {
              description = "ARCS Production Environment"
              tags        = { Environment = "Production", Application = "ARCS", Compliance = "SOX" }
            }
            "ARCS-Test" = {
              description = "ARCS Test/UAT Environment"
              tags        = { Environment = "Test", Application = "ARCS" }
            }
          }
        }
        "Other-EPM" = {
          description = "Other EPM Applications (Planning, EDMCS, Freeform) - Parked"
          children = {
            "Planning" = {
              description = "Oracle Planning Cloud - Future Migration"
              tags        = { Environment = "Parked", Application = "Planning" }
            }
            "EDMCS" = {
              description = "Enterprise Data Management Cloud - Future Migration"
              tags        = { Environment = "Parked", Application = "EDMCS" }
            }
            "Freeform" = {
              description = "Freeform Planning - Future Migration"
              tags        = { Environment = "Parked", Application = "Freeform" }
            }
          }
        }
      }
    }
  }
}