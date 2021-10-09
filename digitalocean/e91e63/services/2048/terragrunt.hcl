include "domain" {
  path = find_in_parent_folders("domain.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  route_conf = {
    active      = true
    middlewares = []
  }
  service_conf = {
    container_port = 80
    image          = "alexwhen/docker-2048"
    name           = "game-2048"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
