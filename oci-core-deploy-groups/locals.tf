# Update locals.tf to handle empty CSV fields better
locals {
  # Parse CSV without external shell script
  csv_content = try(file("${path.module}/csv_groups.csv"), "")
  csv_lines   = compact(split("\n", local.csv_content))

  # Convert CSV to map - handle empty fields
  groups_from_csv = {
    for line in slice(local.csv_lines, 1, length(local.csv_lines)) :
    split(",", line)[0] => {
      name = split(",", line)[0]
      description = coalesce(
        try(trimspace(split(",", line)[1]), ""),
        "${split(",", line)[0]} group"
      )
      freeform_tags = {
        Environment = coalesce(
          try(trimspace(split(",", line)[2]), ""),
          "PROD"
        )
        Owner = coalesce(
          try(trimspace(split(",", line)[3]), ""),
          "Finance"
        )
      }
    }
    if length(split(",", line)) > 0 && split(",", line)[0] != ""
  }

  # Use provided groups or CSV groups
  groups = var.use_csv ? local.groups_from_csv : var.iam_groups
}