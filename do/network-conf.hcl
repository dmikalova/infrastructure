inputs = {
  // Small default VPCs
  vpcs_default = {
    ams1 = {
      ip_range = "10.243.0.0/24"
    }
    ams2 = {
      ip_range = "10.243.1.0/24"
    }
    ams3 = {
      ip_range = "10.243.2.0/24"
    }
    blr1 = {
      active   = true
      ip_range = "10.243.3.0/24"
    }
    fra1 = {
      ip_range = "10.243.4.0/24"
    }
    lon1 = {
      ip_range = "10.243.5.0/24"
    }
    nyc1 = {
      active   = true
      ip_range = "10.243.6.0/24"
    }
    nyc2 = {
      ip_range = "10.243.7.0/24"
    }
    nyc3 = {
      active   = true
      ip_range = "10.243.8.0/24"
    }
    sfo1 = {
      ip_range = "10.243.9.0/24"
    }
    sfo2 = {
      active   = true
      ip_range = "10.243.10.0/24"
    }
    sfo3 = {
      active   = true
      ip_range = "10.243.11.0/24"
    }
    sgp1 = {
      ip_range = "10.243.12.0/24"
    }
    tor1 = {
      ip_range = "10.243.13.0/24"
    }
  }

  vpcs_managed = {
    // Planning to use 10.x.0.0/16 for K8s VPCs
    // https://docs.digitalocean.com/products/networking/vpc/#limits
    sfo3 = {
      "673ab7" = "10.0.0.0/16"
    }
  }
}
