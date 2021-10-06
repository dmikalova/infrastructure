include {
  path = find_in_parent_folders()
}

inputs = {
  k8s_conf           = read_terragrunt_config(find_in_parent_folders("kubernetes.hcl")).dependency.kubernetes.outputs.conf
  load_balancer_info = read_terragrunt_config(find_in_parent_folders("load-balancer.hcl")).dependency.load_balancer.outputs.info
  project_conf       = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git//modules/domain/"
}
