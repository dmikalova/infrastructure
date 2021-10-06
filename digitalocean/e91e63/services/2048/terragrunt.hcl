dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  _2048_conf = {
    domain_name = "e91e63.tech"
    image       = "alexwhen/docker-2048"
    name        = "game-2048"
  }
  k8s_conf = dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/2048/"
}
