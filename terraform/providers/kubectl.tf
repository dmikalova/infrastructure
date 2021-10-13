provider "kubectl" {
  apply_retry_count      = 5
  host                   = var.k8s_info.host
  token                  = var.k8s_info.token
  cluster_ca_certificate = base64decode(var.k8s_info.cluster_ca_certificate)
  load_config_file       = false
}
