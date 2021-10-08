dependency "kubernetes" {
  config_path = "../kubernetes"
}

dependency "load_balancer" {
  config_path = "../load-balancer"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  k8s_info           = dependency.kubernetes.outputs.info
  load_balancer_info = dependency.load_balancer.outputs.info
  project_conf       = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git//modules/domain/"
}
