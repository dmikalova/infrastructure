dependency "middleware_admins" {
  config_path = find_in_parent_folders("e91e63/manifests/traefik/middleware-admins")
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
  route_conf = {
    active      = true
    middlewares = [dependency.middleware_admins.outputs.info]
  }
  service_conf = {
    container_port = 5000
    image          = local.image
    name           = "todo"
  }
}

locals {
  image = "v0.0.1-dev-62e1bf2"
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
