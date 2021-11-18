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
  conf = {
    name  = "admins"
    users = jsondecode(sops_decrypt_file(find_in_parent_folders("traefik-users.sops.json"))).admins,
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git//modules/traefik/middlewares/basic-auth/"
}
