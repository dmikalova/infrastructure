dependencies {
  paths = [
    "../traefik/",
  ]
}

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
    chart         = "consul"
    chart_version = "v0.33.0"
    name          = "consul"
    repository    = "https://helm.releases.hashicorp.com"
    values = {
      connectInject = {
        default = false
        enabled = true
      }
      controller = {
        enabled = true
      }
      global = {
        name       = "consul"
        datacenter = "dc1"
        metrics = {
          enabled = true
        }
        # tls = {
        #   # acls = {
        #   #   manageSystemACLs = true
        #   # }
        #   enabled           = true
        #   enableAutoEncrypt = true
        #   # gossipEncryption = {
        #   #   secretName = "consul-gossip-encryption-key"
        #   #   secretKey  = "key"
        #   # }
        #   verify = true
        #   serverAdditionalDNSSANs = [
        #     "consul-server.default.svc.cluster.local"
        #   ]
        # }
      }
      grafana = {
        enabled = true
      }
      prometheus = {
        enabled = true
      }
      syncCatalog = {
        default  = false
        enabled  = true
        toConsul = true
        toK8S    = false
      },
      ui = {
        enabled = true
      }
    }
  }
  route_conf = {
    active       = true
    middlewares  = [dependency.middleware_admins.outputs.info]
    service_name = "consul-ui"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-manifests.git//modules/helm-chart/"
}
