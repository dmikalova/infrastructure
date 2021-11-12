dependencies {
  paths = [
    find_in_parent_folders("traefik"),
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
    name  = "admins"
    users = jsondecode(sops_decrypt_file(find_in_parent_folders("traefik-users.sops.json"))).admins,
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik-middleware-basic-auth/"
}
