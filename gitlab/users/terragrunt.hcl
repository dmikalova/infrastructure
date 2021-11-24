include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    gitlab_token = local.secrets.gitlab.GITLAB_TOKEN
    usernames = [
      "dmikalova"
    ]
  }
}

locals {
  secrets = {
    gitlab = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/gitlab.sops.json")))
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-gitlab-projects.git///modules/users"
}
