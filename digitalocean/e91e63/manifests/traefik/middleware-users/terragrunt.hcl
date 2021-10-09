dependencies {
  paths = [
    "../../../services/traefik/"
  ]
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  basic_auth_conf = {
    name = "users"
    users = concat(
      local.users_file.admins,
      local.users_file.users,
    )
  }
}

locals {
  users_file = jsondecode(sops_decrypt_file(find_in_parent_folders("traefik-users.sops.json")))
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik-middleware-basic-auth/"
}
