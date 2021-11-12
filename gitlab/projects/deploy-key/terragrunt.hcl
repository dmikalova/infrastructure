dependency "projects" {
  config_path = find_in_parent_folders("projects")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    ecdsa_curve = "P256"
    gitlab_projects = dependency.projects.outputs.info
    title        = "infrastructure-deploy-key"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-gitlab-projects.git///modules/deploy-key"
}
