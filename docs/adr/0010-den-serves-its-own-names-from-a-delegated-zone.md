# 10. den serves its own names from a delegated zone

This decision records how `den.mklv.tech` resolves, how it gets a
certificate, and why den is the first host here to hold a DNS credential.

## Context

den runs services with web interfaces. Until now they were reached over the
tailnet by IP or by a MagicDNS name, over plain HTTP. Neither is acceptable
to a browser, and an IP is not a name anyone wants to type.

The obvious shortcut does not work. A `CNAME` from `mklv.tech` to den's
`ts.net` name resolves only inside Tailscale: a public recursor asked for
`den.tailde21e0.ts.net` returns nothing, so the chain dead-ends. Pointing the
record directly at den's tailnet IP does work, because a name may resolve to
an address that only some clients can route to.

That settles resolution but not trust. Every certificate in this estate so
far has been a Google-managed certificate on a Cloud Run domain mapping,
issued because Google both terminates the connection and controls the name.
den terminates its own connections, and nothing reaches it from the public
internet, so HTTP-01 validation cannot work. DNS-01 can, but it requires
something on den to write a TXT record into a Cloud DNS zone on every
renewal.

The only account that could write DNS was `tofu-ci`, which holds
`roles/dns.admin` across the whole project. ADR 0008 is explicit that a host
account is granted access per resource and never a project-wide role.

## Decision

**den owns a delegated zone, and holds a credential scoped to that zone
alone.**

- **`den.mklv.tech` is its own Cloud DNS managed zone,** delegated from
  `mklv.tech` with `NS` records and, because the parent is signed, `DS`
  records. A credential scoped to this zone can break den's names and no
  others.
- **Records point at den's tailnet addresses,** read from the
  `/tailscale/tailnet` stack rather than written down. The names are public;
  the addresses are not routable from outside the tailnet, so publishing them
  costs nothing and reveals nothing an off-tailnet client can use.
- **Caddy on den obtains a wildcard certificate for `*.den.mklv.tech` by
  DNS-01,** using the existing `den-host` service account. This is the first
  ACME in the estate.
- **The `den-host` account is granted `roles/dns.admin` on the child zone
  only.** A second account for DNS would mean a second key on the same disk,
  which is a different name for the same blast radius.
- **It also holds a custom project role carrying `dns.managedZones.list`
  alone.** The ACME client resolves a zone name to a zone id by listing the
  project's zones, so a per-zone grant on its own returns 403 before any
  record is written.
- **Each service gets a name, not a path.** `beszel.den.mklv.tech` rather
  than `den.mklv.tech/beszel`, because an app that assumes it owns `/` is the
  common case and rewriting its links is work that never ends.

## Consequences

The first apply of `/den/dns` fails on a fresh tailnet, because den's
addresses cannot be read until den has enrolled, and den enrols using a key
this repository issues. This is an ordering gap, not a cycle: the stack is
applied again once den is up. It is deliberately not tagged `manual`, so the
gap fails loudly rather than being skipped forever.

Zone-scoped `roles/dns.admin` is wider than writing TXT records. Cloud DNS
has no predefined role for record sets alone, so the alternative is a custom
role. The zone holds nothing but den's own names, so the gap between what the
role allows and what den needs is bounded by a blast radius den already has.

ADR 0008 says a host account is never granted a project-wide role. The zone
lister is one, and this ADR narrows that rule rather than keeping it intact:
a host may hold a project role that reads metadata it cannot act on. The
permission returns zone names and nameservers, both already published in
public DNS, and no record data and no write. The rule it replaces was aimed
at predefined roles such as `roles/dns.reader`, which would hand den every
record in every zone in the estate.

Certificate renewal now depends on Cloud DNS being reachable from den. A
renewal failure is silent for up to thirty days before it becomes an outage,
so it belongs in the monitoring den already reports to Discord.
