dependency "kubernetes" {
  config_path = find_in_parent_folders("e91e63/kubernetes")
}

generate "kubectl" {
  contents  = file(find_in_parent_folders("terraform/providers/kubectl.tf"))
  if_exists = "overwrite"
  path      = "provider-kubectl.tf"
}

generate "kubernetes" {
  contents  = file(find_in_parent_folders("terraform/providers/kubernetes.tf"))
  if_exists = "overwrite"
  path      = "provider-kubernetes.tf"
}

inputs = {
  k8s_info = dependency.kubernetes.outputs.info
}
