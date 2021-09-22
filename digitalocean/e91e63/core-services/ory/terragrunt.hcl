dependencies {
  paths = [
    "../../kubernetes/"
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

dependency "postgresql" {
  config_path = "../../postgresql/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  kube_config     = dependency.kubernetes.outputs.kube_config
  postgresql_conf = dependency.postgresql.outputs.terraform_role
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/ory/"
}
