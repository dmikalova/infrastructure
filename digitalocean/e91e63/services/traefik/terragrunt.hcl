dependency "traefik_users" {
  config_path = "../../secrets/traefik-users"
}

include "helm" {
  path = find_in_parent_folders("helm.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  traefik_conf = {
    users   = dependency.traefik_users.outputs.info,
    version = "10.3.6",
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git//modules/traefik/"
}
