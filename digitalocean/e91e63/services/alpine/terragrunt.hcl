include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  pod_conf = {
    command = ["sleep", "infinity"]
    image   = "alpine"
    name    = "alpine"
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git///modules/pod/"
}
