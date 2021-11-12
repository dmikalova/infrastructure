dependency "middleware_admins" {
  config_path = find_in_parent_folders("e91e63/services/traefik/middlewares/admins")
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
    image          = local.image
    name           = "todo"
    port_container = 5000
    route = {
      middlewares = [dependency.middleware_admins.outputs.info]
    }
  }
}

locals {
  image = "registry.digitalocean.com/dmikalova/cddc39/todo:v0.0.1-dev-b0b7d69"
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
