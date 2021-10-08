dependency "domain" {
  config_path = "../../domain/"
}

include {
  // TODO: Have services.hcl load kubernetes dependency
  path = find_in_parent_folders()
}

inputs = {
  domain_info = dependency.domain.outputs.info
  k8s_info    = read_terragrunt_config(find_in_parent_folders("kubernetes.hcl")).dependency.kubernetes.outputs.info
  service_conf = {
    container_port = 5000
    image          = "registry.digitalocean.com/e91e63/todo:0.0.1"
    name           = "todo"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git///modules/service-manifest/"
}
