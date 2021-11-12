inputs = {
  networks = {
    vpcs = {
      // Planning to use 10.x.0.0/16 for K8s VPCs
      // https://docs.digitalocean.com/products/networking/vpc/#limits
      sfo3 = {
        e91e63 = "10.0.0.0/16"
      }
    }
  }
}
