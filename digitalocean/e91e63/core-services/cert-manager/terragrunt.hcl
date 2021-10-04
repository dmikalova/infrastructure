dependencies {
  paths = [
    "../../kubernetes/",
    "../../secrets/digitalocean/",
    "../../secrets/profile/",
  ]
}

dependency "digitalocean" {
  config_path = "../../secrets/digitalocean"
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

dependency "profile" {
  config_path = "../../secrets/profile"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  cert_manager_conf = merge(
    dependency.digitalocean.outputs.info,
    dependency.profile.outputs.info,
    { version = "v1.5.4" }
  )
  k8s_conf = dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/cert-manager/"
}
