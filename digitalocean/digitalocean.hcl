inputs = {
  networks = {
    // Small default VPCs
    vpcs_default = {
      blr1 = { active = true }
      nyc1 = { active = true }
      nyc3 = { active = true }
      sfo2 = { active = true }
      sfo3 = { active = true }
    }

    vpcs_managed = {
      // Planning to use 10.x.0.0/16 for K8s VPCs
      // https://docs.digitalocean.com/products/networking/vpc/#limits
      sfo3 = {
        e91e63 = "10.0.0.0/16"
      }
    }
  }
}
