dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  k8s_conf = dependency.kubernetes.outputs.conf
  whoami_conf = {
    domain_name = "e91e63.tech"
    image       = "containous/whoami"
    name        = "whoami"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/whoami/"
}
