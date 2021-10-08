dependencies {
  paths = [
    "../../e91e63/services/cert-manager/"
  ]
}

dependency "load_balancer" {
  config_path = "../../e91e63/load-balancer/"
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

include "project" {
  path = find_in_parent_folders("project.hcl")
}

inputs = {}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git///modules/domain/"
}
