dependency "traefik" {
  config_path = find_in_parent_folders("traefik/")
}

dependency "middleware_public" {
  config_path = find_in_parent_folders("traefik/middlewares/public")
}

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
  conf = {
    image = "alexwhen/docker-2048"
    name  = "game-2048"
    route = {
      active      = true
      middlewares = [dependency.middleware_public.outputs.info]
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
