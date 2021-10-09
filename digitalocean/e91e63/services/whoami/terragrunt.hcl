dependency "middleware_users" {
  config_path = "../../manifests/traefik/middleware-users"
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
    middlewares = [dependency.middleware_users.outputs.info]
  }
  service_conf = {
    container_port = 80
    image          = "containous/whoami"
    name           = "whoami"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
