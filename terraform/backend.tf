terraform {
  backend "s3" {
    bucket                      = "e91e63"
    encrypt                     = true
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    key                         = "tfstates/${path}/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
