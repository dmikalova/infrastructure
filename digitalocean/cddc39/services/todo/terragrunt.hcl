dependency "domain" {
  config_path = "../../domain/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  service_conf = {
    domain_name = dependency.domain.outputs.domain_name
    image       = "registry.digitalocean.com/e91e63/todo:0.0.1"
    name        = "todo"
  }
  k8s_conf = read_terragrunt_config(find_in_parent_folders("kubernetes.hcl")).dependency.kubernetes.outputs.conf
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-deployments.git///modules/2048/"
}
