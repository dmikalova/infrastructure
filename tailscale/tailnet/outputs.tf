# IPv4 only: den/dns publishes A records and no AAAA, because `den apply`
# keeps den's IPv4 across a reinstall and Tailscale cannot do the same for
# its IPv6.

output "den_ipv4_addresses" {
  description = "den's tailnet IPv4 addresses, for A records"
  value       = [for address in data.tailscale_device.den.addresses : address if !strcontains(address, ":")]
}
