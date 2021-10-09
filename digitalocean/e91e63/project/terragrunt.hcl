inputs = {
  project_conf = {
    description = "Infrastructure"
    environment = "Production"
    name        = "e91e63"
    purpose     = "Operational / Developer tooling"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git///modules/project/"
}
