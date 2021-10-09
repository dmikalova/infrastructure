dependency "middleware_admins" {
  config_path = "../../manifests/traefik/middleware-admins"
}

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
    chart         = "traefik"
    chart_version = "10.3.6"
    name          = "traefik"
    repository    = "https://helm.traefik.io/traefik"
    values = {
      additionalArguments = [
        "--entryPoints.web.http.redirections.entryPoint.scheme=https",
        "--entryPoints.web.http.redirections.entryPoint.to=websecure",
        // "--providers.consulcatalog.connectAware=true",
        // "--providers.consulcatalog.connectByDefault=true",
        // "--providers.consulcatalog.exposedByDefault=false",
      ]
      deployment = {
        kind = "DaemonSet"
      }
      ingressRoute = {
        dashboard = {
          enabled = false
        }
      }
      ports = {
        web = {
          nodePort = 32080
          port     = 8080
        }
        websecure = {
          nodePort = 32443
          port     = 8443
        }
      }
      service = {
        type = "NodePort"
      }
    }
    // route_conf = {
    //   active      = true
    //   middlewares = [dependency.middleware_admins.outputs.info]
    // }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/helm-chart/"
}
