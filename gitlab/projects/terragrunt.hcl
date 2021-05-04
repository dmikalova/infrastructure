terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  gitlab_conf = read_terragrunt_config(find_in_parent_folders("gitlab-conf.hcl")).inputs
}
