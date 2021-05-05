terraform {
  source = "git@gitlab.com:673ab6/terraform-digitalocean-account-baseline.git"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  network_conf = read_terragrunt_config(find_in_parent_folders("network-conf.hcl")).inputs
}
