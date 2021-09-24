include {
  path = find_in_parent_folders()
}

inputs = {
  k8s_conf     = { version = "1.21" }
  project_conf = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

// TODO redeploy to sfo3
terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git//"
}
