dependencies {
  paths = [
    "../../cert-manager"
  ]
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  cert_issuer_conf = {
    email                              = jsondecode(sops_decrypt_file(find_in_parent_folders("profile.sops.json"))).email,
    digitalocean_personal_access_token = jsondecode(sops_decrypt_file(find_in_parent_folders("digitalocean/credentials-digitalocean.sops.json"))).DIGITALOCEAN_TOKEN,
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/digitalocean-cert-issuer/"
}
