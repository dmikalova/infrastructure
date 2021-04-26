terraform {
  source = "git@gitlab.com:673ab6/terraform-digitalocean-metadata.git//"
}

include {
  path = find_in_parent_folders()
}

inputs = {}
