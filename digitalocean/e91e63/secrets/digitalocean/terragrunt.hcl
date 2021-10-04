dependencies {
  paths = [
    "../../metadata",
  ]
}

dependency "metadata" {
  config_path = "../../metadata"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  info_conf = merge(
    dependency.metadata.outputs.info_conf,
    { key = "secrets/digitalocean.json" },
  )
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-metadata.git//modules/info-read"
}
