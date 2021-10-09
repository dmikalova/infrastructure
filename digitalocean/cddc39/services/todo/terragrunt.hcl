include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  service_conf = {
    container_port = 5000
    image          = "registry.digitalocean.com/e91e63/todo:0.0.1"
    name           = "todo"
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-kubernetes-services.git///modules/service-manifest/"
}
