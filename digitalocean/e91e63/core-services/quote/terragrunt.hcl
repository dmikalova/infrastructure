dependencies {
  paths = [
    "../../kubernetes/"
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  kube_config = dependency.kubernetes.outputs.kube_config
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/consul/"
}
