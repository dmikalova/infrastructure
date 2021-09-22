dependencies {
  paths = [
    "../../kubernetes/",
    "../../secrets/google-oauth"
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

dependency "google_oauth" {
  config_path = "../../secrets/google-oauth"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  kube_config  = dependency.kubernetes.outputs.kube_config
  google_oauth = dependency.google_oauth.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/helm/"
}
