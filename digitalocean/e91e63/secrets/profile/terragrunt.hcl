dependency "metadata" {
  config_path = "../../metadata"
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  info_conf = merge(
    dependency.metadata.outputs.info_conf,
    { key = "secrets/profile.json" },
  )
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git//modules/info-read"
}
