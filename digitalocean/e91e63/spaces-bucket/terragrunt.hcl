dependency "project" {
  config_path = "../project/"
}

dependency "vpc" {
  config_path = "../vpc/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  bucket_conf  = { region = dependency.vpc.outputs.info.region }
  project_info = dependency.project.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-spaces.git///modules/bucket"
}