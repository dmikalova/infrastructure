include {
  path = find_in_parent_folders()
}

inputs = {
  // TODO use nodeports from cluster
  lb_conf      = {}
  project_conf = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git///"
}
