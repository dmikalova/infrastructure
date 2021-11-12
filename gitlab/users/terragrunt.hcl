include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    gitlab_token = jsondecode(sops_decrypt_file(find_in_parent_folders("credentials-gitlab.sops.json"))).GITLAB_TOKEN
    usernames = [
      "dmikalova"
    ]
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-gitlab-projects.git///modules/users"
}
