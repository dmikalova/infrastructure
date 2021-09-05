terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git"
}

include {
  path = find_in_parent_folders()
}

inputs = {}
