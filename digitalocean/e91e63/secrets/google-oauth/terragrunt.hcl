include {
  path = find_in_parent_folders()
}

inputs = {
  info_conf = {
    bucket = "e91e63"
    key    = "secrets/google-oauth.json"
    region = "sfo3"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git///modules/info-read"
}
