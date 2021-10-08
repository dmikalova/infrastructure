include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  _2048_conf = {
    domain_name = "e91e63.tech"
    image       = "alexwhen/docker-2048"
    name        = "game-2048"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git///modules/2048/"
}
