dependencies {
  paths = [
    "../kubernetes",
    "../secrets/profile",
  ]
}

dependency "profile" {
  config_path = "../secrets/profile"
}

dependency "kubernetes" {
  config_path = "../kubernetes"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  acme_conf    = dependency.profile.outputs.info
  k8s_conf     = dependency.kubernetes.outputs.conf
  project_conf = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git//modules/domain/"
}
