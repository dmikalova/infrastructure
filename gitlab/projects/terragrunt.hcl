include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  gitlab = read_terragrunt_config(find_in_parent_folders("gitlab.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git///"
}
