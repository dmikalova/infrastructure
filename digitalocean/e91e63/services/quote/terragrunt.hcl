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
  k8s_info = dependency.kubernetes.outputs.info
  quote_conf = {
    domain_name = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs.domain_name
    email       = dependency.profile.outputs.info.email
    image       = "docker.io/datawire/quote:0.5.0"
    name        = "quote"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-helm-charts.git///modules/quote/"
}
