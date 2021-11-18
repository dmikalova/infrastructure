include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "cddc39"
    repositories = {
      lists = {
        description  = "manage lists"
        organization = "cddc39"
        visibility   = "public"
      },
      recipes = {
        description = "manage recipes"
        topics      = ["javascript"]
        visibility  = "public"
      },
      todos = {
        description = "manage todos with automated planning"
        topics      = ["javascript"]
        visibility  = "public"
      },
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
