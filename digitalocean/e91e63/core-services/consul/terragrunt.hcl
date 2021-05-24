dependencies {
    paths = [
        "../../kubernetes"
    ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  kube_config = dependency.kubernetes.outputs.kube_config
  kube_config = {
      host = "x"
      token = "x"
      kube_config = "x"
      client_certificate = "x"
      client_key = "x"
      cluster_ca_certificate = "x"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/consul/"
}
