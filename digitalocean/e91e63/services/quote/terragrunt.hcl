dependency "middleware_admins" {
  config_path = find_in_parent_folders("traefik/middlewares/admins")
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
    image          = "docker.io/datawire/quote:0.5.0"
    name           = "quote"
    port_container = 8080
    route = {
      active      = true
      middlewares = [dependency.middleware_admins.outputs.info]
    }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
