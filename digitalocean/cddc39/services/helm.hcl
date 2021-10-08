dependency "domain" {
  config_path = "${get_parent_terragrunt_dir()}/../domain/"
}

dependency "kubernetes" {
  config_path = "${get_parent_terragrunt_dir()}/../../e91e63/kubernetes/"
}

generate "helm" {
  contents  = file(find_in_parent_folders("terraform/providers/helm.tf"))
  if_exists = "overwrite"
  path      = "provider-helm.tf"
}

generate "kubernetes" {
  contents  = file(find_in_parent_folders("terraform/providers/kubernetes.tf"))
  if_exists = "overwrite"
  path      = "provider-kubernetes.tf"
}

inputs = {
  domain_info = dependency.domain.outputs.info
  k8s_info    = dependency.kubernetes.outputs.info
}
