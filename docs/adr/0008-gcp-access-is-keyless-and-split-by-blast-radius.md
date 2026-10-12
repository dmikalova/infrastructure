# 8. GCP access is keyless and split by blast radius

This decision records how GitHub Actions authenticates to GCP, and why there
are two service accounts rather than one.

## Context

A service account key is a long-lived credential in a file. Once issued it can
be copied, it does not expire, and nothing reports that it has leaked. GitHub
Actions can instead present a short-lived OIDC token, which GCP will exchange
for a scoped, expiring credential.

Not every workflow needs the same power. Applying infrastructure requires
broad permissions. Deploying a container image requires almost none.

## Decision

**No workload that can federate holds a service account key. Workloads
federate, and they federate into one of two accounts.** See the amendment
below for hosts that have no identity provider to federate with.

- **A workload identity pool named `github` trusts
  `https://token.actions.githubusercontent.com`,** mapping `repository`,
  `repository_owner`, `ref` and `actor`.
- **`github-actions-infra` can change infrastructure** and is bound to
  `dmikalova/infrastructure` alone.
- **`github-actions-deploy` holds `roles/run.developer`** and is bound to the
  repositories carrying the `mklv-deploy` topic (ADR 0004). It can ship a
  revision and nothing else (ADR 0005).
- **Local development uses Application Default Credentials and impersonates the
  same service accounts,** so a human and a pipeline exercise identical
  permissions. A plan that works locally is not using powers CI lacks.

## Amendment: bare-metal hosts hold one sealed key

Federation needs an identity provider. GitHub Actions has one. `den` is a
machine in a cupboard and has none, so it cannot federate. The choice is a
long-lived key or no access at all.

**A bare-metal host may hold one service account key, sealed to its TPM.**

- **The key is encrypted with `systemd-creds` against the host TPM2 device.**
  The file on disk is useless on any other machine. A stolen drive yields
  ciphertext.
- **The account is named for the host and is granted access per secret.** It
  is never granted a project-wide role. The list of secrets it can read is the
  definition of its blast radius, and that list lives in this repository.
- **Installer secrets stay out of reach.** The host must not be able to read
  the passphrase to its own disk. Secrets used to build the machine are a
  separate secret carrying no binding at all, so only project admins reach
  them.
- **The key is minted here, not by the host.** A key a machine issues for
  itself has no declared owner, outlives a rebuild, and can only be revoked by
  someone who first works out that it exists.
- **The key is the only credential delivered to the host.** Everything else is
  fetched. A second delivery channel would recreate the problem this amendment
  exists to avoid.

The asymmetry with federation is real and is the price of running hardware. A
key can be copied before anyone notices. The mitigations are that it is useless
off the machine, that it reads a short list rather than a project, and that
deleting it in GCP revokes it everywhere at once.

## Consequences

Access is granted by changing a binding, and revoked by changing it back. For
federated workloads there is no key to rotate and nothing to leak into a log.
For a bare-metal host there is exactly one key, and revoking it is still a
single action.

The two accounts must stay asymmetric. Adding a convenience role to
`github-actions-deploy` because one workflow needed it would dissolve the
distinction and hand every application repository the ability to rewrite its
own service.

A host account must never become a second `github-actions-infra`. If a host
needs a new secret, the binding for that secret changes. The role does not.
