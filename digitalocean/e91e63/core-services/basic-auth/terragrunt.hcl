dependencies {
  paths = [
    "../../kubernetes/",
    "../../secrets/basic-auth"
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

dependency "basic_auth" {
  config_path = "../../secrets/basic-auth"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  basic_auth  = dependency.basic_auth.outputs.info
  kube_config = dependency.kubernetes.outputs.kube_config
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/helm/"
}
