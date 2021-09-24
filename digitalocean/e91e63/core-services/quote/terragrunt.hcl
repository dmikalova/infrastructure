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
  k8s_conf   = dependency.kubernetes.outputs.conf
  quote_conf = { image = "docker.io/datawire/quote:0.5.0" }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/quote/"
}
