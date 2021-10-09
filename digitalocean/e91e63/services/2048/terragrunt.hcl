include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  service_conf = {
    image       = "alexwhen/docker-2048"
    middlewares = []
    name        = "game-2048"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git///modules/service-manifest/"
}
