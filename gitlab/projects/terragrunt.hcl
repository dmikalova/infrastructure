dependency "deploy_key" {
  config_path = find_in_parent_folders("deploy-key/")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  gitlab = merge(
    {
      deploy_key = dependency.deploy_key.outputs.info,
    },
    read_terragrunt_config(find_in_parent_folders("gitlab.hcl")).inputs
  )
}

terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git///"
}
