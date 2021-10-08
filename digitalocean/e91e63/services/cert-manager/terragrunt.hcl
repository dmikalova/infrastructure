dependency "digitalocean" {
  config_path = "../../secrets/digitalocean"
}

dependency "profile" {
  config_path = "../../secrets/profile"
}

include "helm" {
  path = find_in_parent_folders("helm.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  cert_manager_conf = merge(
    dependency.digitalocean.outputs.info,
    dependency.profile.outputs.info,
    { version = "v1.5.4" }
  )
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git//modules/cert-manager/"
}
