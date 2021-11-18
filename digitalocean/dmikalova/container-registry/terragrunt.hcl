include "project" {
  path = find_in_parent_folders("project.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  container_registry_conf = {
    name                   = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs.name
    subscription_tier_slug = "basic"
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-digitalocean-kubernetes.git//modules/container-registry/"
}
