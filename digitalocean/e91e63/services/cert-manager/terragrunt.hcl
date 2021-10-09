include "domain" {
  path = find_in_parent_folders("domain.hcl")
}

include "helm" {
  path = find_in_parent_folders("helm.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  helm_conf = {
    chart         = "cert-manager"
    chart_version = "v1.5.4"
    name          = "cert-manager"
    repository    = "https://charts.jetstack.io"
    values = {
      installCRDs = true
    }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/helm-chart/"
}
