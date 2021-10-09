dependency "project" {
  config_path = "../project/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  project_info = dependency.project.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-postgresql.git///"
}
