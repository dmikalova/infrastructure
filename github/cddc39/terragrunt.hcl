include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "cddc39"
    repositories = {
      lists = {
        description      = "manage lists"
        organization     = "cddc39"
        visibility_level = "public"
      },
      recipes = {
        description      = "manage recipes"
        topics           = ["javascript"]
        visibility_level = "public"
      },
      rem = {
        description = "An app for spaced repetition flashcards"
      },
      rem-vue = {
        description = "An app for spaced repetition flashcards"
      },
      rurl = {
        description = "A site that redirects to a random url from a list"
      },
      todos = {
        description      = "manage todos with automated planning"
        topics           = ["javascript"]
        visibility_level = "public"
      },
      toto = {
        description      = "a todo list app"
        visibility_level = "public"
      },
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
