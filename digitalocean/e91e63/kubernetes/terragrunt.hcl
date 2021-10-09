dependency "project" {
  config_path = "../project/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  k8s_conf = { version = "1.21" }
  project_info       = dependency.project.outputs.info
  // project_info = {
  //   name = "e91e63"
  //   id   = "this"
  // }
}

// TODO redeploy to sfo3
terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git///"
}
