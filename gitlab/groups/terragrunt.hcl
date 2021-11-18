include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    groups = {
      cddc39 = {
        description = "Containerized web services"
      },
      e91e63 = {
        description = "Terraform modules for managing Digital Ocean Kubernetes clusters"
      }
      screeptorio = {
        description = "Screeps private server"
      }
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-gitlab-projects.git///modules/groups"
}
