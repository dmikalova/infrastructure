dependency "load_balancer" {
  config_path = "../../load-balancer/"
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
  conf = {
    helm = {
      chart         = "traefik"
      chart_version = "10.3.6"
      name          = "traefik"
      namespace     = "default"
      repository    = "https://helm.traefik.io/traefik"
      values = {
        additionalArguments = [
          "--entryPoints.web.http.redirections.entryPoint.scheme=https",
          "--entryPoints.web.http.redirections.entryPoint.to=websecure",
          // "--providers.consulcatalog.connectAware=true",
          // "--providers.consulcatalog.connectByDefault=true",
          // "--providers.consulcatalog.exposedByDefault=false",
          "--providers.kubernetescrd.allowCrossNamespace=true",
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
            nodePort = dependency.load_balancer.outputs.info.http_target_port
            port     = 8080
          }
          websecure = {
            nodePort = dependency.load_balancer.outputs.info.https_target_port
            port     = 8443
          }
        }
        service = {
          type = "NodePort"
        }
      }
    }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/helm-chart/"
}
