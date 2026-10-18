# Split by family here rather than in the consumer: A and AAAA are separate
# record sets, and nothing else wants the mixed list.

output "den_ipv4_addresses" {
  description = "den's tailnet IPv4 addresses, for A records"
  value       = [for address in data.tailscale_device.den.addresses : address if !strcontains(address, ":")]
}

output "den_ipv6_addresses" {
  description = "den's tailnet IPv6 addresses, for AAAA records"
  value       = [for address in data.tailscale_device.den.addresses : address if strcontains(address, ":")]
}
