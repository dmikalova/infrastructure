include "helm" {
  path = find_in_parent_folders("helm.hcl")
}

inputs = {
  helm_conf = {
    chart         = "argo-workflows"
    chart_version = "0.7.1"
    name          = "argo-workflows"
    repository    = "https://argoproj.github.io/argo-helm"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git//modules/helm-chart/"
}
