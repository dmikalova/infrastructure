// This manifest is needed to break dependency cycles
dependency "traefik" {
  config_path = find_in_parent_folders("traefik")
}

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
    middlewares = [dependency.middleware_admins.outputs.info]
    kind        = "TraefikService"
    service = {
      name      = "api@internal"
      namespace = dependency.traefik.outputs.info.namespace
      port      = 9000
    }
    subdomain = "traefik"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik/ingress-route/"
}
