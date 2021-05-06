include {
  path = find_in_parent_folders()
}

inputs = {
  gitlab = read_terragrunt_config(find_in_parent_folders("gitlab.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git"
}
