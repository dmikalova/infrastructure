include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
      default_vpcs = {
        blr1 = { active = true }
        nyc1 = { active = true }
        nyc3 = { active = true }
        sfo2 = { active = true }
        sfo3 = { active = true }
      }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-account.git///modules/baseline"
}
