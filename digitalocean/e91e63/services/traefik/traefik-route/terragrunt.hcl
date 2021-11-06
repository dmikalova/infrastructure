// This manifest is needed to break dependency cycles
dependencies {
  paths = [
    "../"
  ]
}

dependency "middleware_admins" {
  config_path = "../../../manifests/traefik/middleware-admins"
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
  service_conf = {
    name = "traefik"
  }
  route_conf = {
    middlewares  = [dependency.middleware_admins.outputs.info]
    service_kind = "TraefikService"
    service_name = "api@internal"
    service_port = 9000
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik-ingress-route/"
}
