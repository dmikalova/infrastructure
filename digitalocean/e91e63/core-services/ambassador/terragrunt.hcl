dependencies {
  paths = [
    "../../kubernetes/",
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  ambassador_conf = { version = "v6.9.1" }
  k8s_conf        = dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/helm/ambassador"
}
