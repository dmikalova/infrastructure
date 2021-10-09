include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  quote_conf = {
    container_port = 8080
    image = "docker.io/datawire/quote:0.5.0"
    name  = "quote"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git///modules/service/"
}
