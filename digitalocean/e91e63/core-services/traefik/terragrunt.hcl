dependencies {
  paths = [
    "../../kubernetes/",
    "../../secrets/traefik-users",
  ]
}

dependency "kubernetes" {
  config_path = "../../kubernetes/"
}

dependency "traefik_users" {
  config_path = "../../secrets/traefik-users"
}


include {
  path = find_in_parent_folders()
}

inputs = {
  traefik_conf = {
    users   = dependency.traefik_users.outputs.info,
    version = "10.3.6",
  }
  k8s_conf = dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git//modules/treafik/"
}
