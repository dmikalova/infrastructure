include {
  path = find_in_parent_folders()
}

inputs = {
  // TODO: move this up
    name = "e91e63"
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git///"
}
