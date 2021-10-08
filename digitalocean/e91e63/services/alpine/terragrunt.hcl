dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  k8s_conf = dependency.kubernetes.outputs.conf
  alpine_conf = {
    image = "alpine"
    name  = "alpine"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/alpine/"
}