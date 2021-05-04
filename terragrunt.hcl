remote_state {
  backend = "s3"
  config = {
    bucket                      = "673ab7"
    encrypt                     = true
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    key                         = "tfstates/${path_relative_to_include()}/terraform.tfstate"
    region                      = "us-east-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
  generate = {
    if_exists = "overwrite"
    path      = "backend.tf"
  }
}
