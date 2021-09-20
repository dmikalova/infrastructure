dependencies {
  paths = [
    "../core-services/ambassador"
  ]
}

dependency "kubernetes" {
  config_path = "../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  acme         = read_terragrunt_config(find_in_parent_folders("acme.hcl")).inputs
  domain_name  = local.project.domain_name
  kube_config  = dependency.kubernetes.outputs.kube_config
  project_name = local.project.project_name
}

locals {
  project = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/domains/"
}
