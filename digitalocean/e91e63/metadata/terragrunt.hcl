include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  do_conf      = read_terragrunt_config(find_in_parent_folders("digitalocean.hcl")).inputs
  project_conf = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git///"
}
