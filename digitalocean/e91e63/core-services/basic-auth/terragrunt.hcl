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
  basic_auth_conf = merge(
    dependency.basic_auth.outputs.info,
    { image = "registry.digitalocean.com/e91e63/basic-auth:0.0.1" }
  )
  k8s_conf = dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/helm/"
}
