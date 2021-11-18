dependencies {
  paths = [
    find_in_parent_folders("traefik"),
  ]
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik/middlewares/null"
}
