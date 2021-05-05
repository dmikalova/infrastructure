include {
  path = find_in_parent_folders()
}

locals {
  # Validate required env vars
  DIGITALOCEAN_TOKEN = get_env("DIGITALOCEAN_TOKEN")
}
