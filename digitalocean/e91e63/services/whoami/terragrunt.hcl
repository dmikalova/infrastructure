dependency "middleware_users" {
  config_path = find_in_parent_folders("traefik/middlewares/users")
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
    image = "containous/whoami"
    name  = "whoami"
    route = {
      middlewares = [dependency.middleware_users.outputs.info]
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
