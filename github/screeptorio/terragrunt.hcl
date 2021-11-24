dependency "workflows" {
  config_path = find_in_parent_folders("digitalocean/e91e63/services/tekton/workflows")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "screeptorio"
    repositories = {
      screeps = {
        description  = "a screeps repo"
        organization = "screeptorio"
      },
      screeps-bot = {
        description  = "a bot to play screeps"
        organization = "screeptorio"
      },
      screeps-mongo-docker = {
        description  = "docker container to deploy screeps server"
        organization = "screeptorio"
      },
    }
  }
  workflows_info = dependency.workflows.outputs.info
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
