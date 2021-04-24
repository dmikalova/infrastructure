terraform {
  source = "../../../terraform-digitalocean-k8s//"
}

include {
  path = find_in_parent_folders()
}

inputs = {
    name = "cddc39"
    region = "sf02"
}
