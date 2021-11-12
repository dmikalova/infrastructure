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
  route_conf = {
    active      = true
    middlewares = [dependency.middleware_admins.outputs.info]
  }
  service_conf = {
    container_port = 8080
    image          = "docker.io/datawire/quote:0.5.0"
    name           = "quote"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
