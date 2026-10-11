stack {
  name        = "Tailscale Tailnet"
  description = "Tailnet policy file and the credentials CI uses to join it"
  id          = "tailscale-tailnet"
  tags        = ["sops", "tailscale"]

  # CI access is derived from the mklv-tailscale topic, so the repos have to
  # carry it before this stack can see them.
  after = ["/github/dmikalova"]
}
