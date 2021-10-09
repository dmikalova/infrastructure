dependency "domain" {
  config_path = "${get_parent_terragrunt_dir()}/domain/"
}

inputs = {
  domain_info = dependency.domain.outputs.info
}
