dependencies {
  paths = [
    "../../account-baseline",
  ]
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  project_conf = {
    description = "Infrastructure"
    environment = "Production"
    name        = "e91e63"
    purpose     = "Operational / Developer tooling"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-account-baseline.git///modules/project/"
}
