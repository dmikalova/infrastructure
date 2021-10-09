inputs = {
  project_conf = {
    description = "Services"
    environment = "Production"
    name        = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs.name
    purpose     = "Web Application"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git///modules/project/"
}
