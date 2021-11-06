provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.k8s_info.cluster_ca_certificate)
  host                   = var.k8s_info.host
  token                  = var.k8s_info.token
}

variable "k8s_info" {
  type = object({
    cluster_ca_certificate = string,
    host                   = string,
    token                  = string,
  })
}
