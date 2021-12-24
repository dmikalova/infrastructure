dependency "workflows" {
  config_path = find_in_parent_folders("digitalocean/e91e63/services/tekton/workflows")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "cddc39"
    repositories = {
      lists = {
        description  = "manage lists"
        topics      = ["javascript"]
        visibility   = "public"
      },
      recipes = {
        description = "manage recipes"
        topics      = ["javascript"]
        visibility  = "public"
      },
      todos = {
        description = "manage todos"
        topics      = ["javascript"]
        visibility  = "public"
      },
    }
  }
  workflows_info = dependency.workflows.outputs.info
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
