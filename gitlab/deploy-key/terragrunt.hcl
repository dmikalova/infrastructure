include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  key_conf = {
    ecdsa_curve = "P256"
    name        = "gitlab-deploy-key"
  }
}

terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git///modules/deploy-key/"
}