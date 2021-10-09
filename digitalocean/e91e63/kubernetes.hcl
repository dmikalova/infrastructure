dependency "kubernetes" {
  config_path = "${get_parent_terragrunt_dir()}/kubernetes/"
}

generate "kubernetes" {
  contents  = file(find_in_parent_folders("terraform/providers/kubernetes.tf"))
  if_exists = "overwrite"
  path      = "provider-kubernetes.tf"
}

inputs = {
  k8s_info = dependency.kubernetes.outputs.info
}
