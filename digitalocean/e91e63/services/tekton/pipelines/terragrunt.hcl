dependency "middleware_admins" {
  config_path = find_in_parent_folders("manifests/traefik/middleware-admins")
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
      name = "tekton-pipelines"
      url = "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.28.1/release.yaml"
  }
//   route_conf = {
//     active       = false
//     middlewares  = [dependency.middleware_admins.outputs.info]
//     service_name = "tekton-pipelines"
//   }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/remote-release/"
}
