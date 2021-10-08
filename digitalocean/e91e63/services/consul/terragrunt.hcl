dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  consul_conf = { version = "v0.33.0" }
  k8s_info    = dependency.kubernetes.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/consul/"
}