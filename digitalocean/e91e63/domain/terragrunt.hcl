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
    acme = read_terragrunt_config(find_in_parent_folders("acme.hcl")).inputs
  domain_name = local.e91e63.domain_name
  project_name = local.e91e63.project_name
  kube_config = dependency.kubernetes.outputs.kube_config
}

locals {
  e91e63 = read_terragrunt_config(find_in_parent_folders("e91e63.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/domains/"
}
