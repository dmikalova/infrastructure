dependency "middleware_admins" {
  config_path = find_in_parent_folders("traefik/middlewares/admins")
}

include "domain" {
  path = find_in_parent_folders("domain.hcl")
}

include "kubectl" {
  path = find_in_parent_folders("kubectl.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  release_conf = {
    name      = "tekton"
    namespace = "tekton-pipelines"
    urls = [
      "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.28.1/release.yaml",
      "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.16.0/release.yaml",
      "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.16.0/interceptors.yaml",
      "https://github.com/tektoncd/dashboard/releases/download/v0.21.0/tekton-dashboard-release.yaml",
    ]
  }
  route_conf = {
    active       = true
    middlewares  = [dependency.middleware_admins.outputs.info]
    service_name = "tekton-dashboard"
    service_port = 9097
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/remote-release/"
}
