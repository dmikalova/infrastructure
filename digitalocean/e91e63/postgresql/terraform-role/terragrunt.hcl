dependency "postgresql" {
  config_path = "../"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  postgresql_info = dependency.postgresql.outputs.info
}

terraform {
  source = "git@github.com:e91e63/terraform-digitalocean-postgresql.git///modules/terraform-role/"
}
