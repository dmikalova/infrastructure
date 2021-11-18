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
  conf = {
    release = {
      name      = "tekton"
      namespace = "tekton-pipelines"
      urls = [
        "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.28.1/release.yaml",
        "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.16.0/release.yaml",
        "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.16.0/interceptors.yaml",
        "https://github.com/tektoncd/dashboard/releases/download/v0.21.0/tekton-dashboard-release.yaml",
      ]
    }
    route = {
      middlewares = [dependency.middleware_admins.outputs.info]
      service = {
        name = "tekton-dashboard"
        port = 9097
      }
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-kubernetes-manifests.git//modules/remote-release/"
}
