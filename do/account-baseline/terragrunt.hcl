terraform {
  source = "git@gitlab.com:673ab6/terraform-digitalocean-account-baseline.git"
}

include {
  path = find_in_parent_folders()
}


inputs = merge(
  jsondecode(file(find_in_parent_folders("networking-conf.json"))),
  {
    active_regions = [
      "blr1",
      "nyc1",
      "nyc3",
      "sfo2",
      "sfo3",
    ]
  },
)
