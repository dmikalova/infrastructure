dependencies {
  paths = [
    find_in_parent_folders("account-baseline"),
  ]
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  project_conf = {
    description = "Services"
    environment = "Production"
    name        = "cddc39"
    purpose     = "Web Application"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-account-baseline.git///modules/project/"
}
