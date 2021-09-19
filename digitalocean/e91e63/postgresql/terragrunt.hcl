include {
  path = find_in_parent_folders()
}

inputs = {
  name = local.e91e63.name
}

locals {
  e91e63 = read_terragrunt_config(find_in_parent_folders("e91e63.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-postgresql.git///"
}
