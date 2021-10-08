include "helm" {
  path = find_in_parent_folders("helm.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  consul_conf = { version = "v0.33.0" }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git//modules/consul/"
}
