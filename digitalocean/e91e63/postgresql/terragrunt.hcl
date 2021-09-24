include {
  path = find_in_parent_folders()
}

include "project" {
  path = find_in_parent_folders("project.hcl")
}

inputs = {
  project_conf = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-postgresql.git//"
}
