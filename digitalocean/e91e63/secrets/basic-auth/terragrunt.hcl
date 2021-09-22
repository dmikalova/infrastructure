include {
  path = find_in_parent_folders()
}

inputs = {
  info_conf = {
    bucket = "e91e63"
    key    = "secrets/basic-auth.json"
    region = "sfo3"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git///modules/info-read"
}
