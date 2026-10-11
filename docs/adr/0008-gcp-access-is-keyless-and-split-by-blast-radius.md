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

**No service account keys exist. Workloads federate, and they federate into
one of two accounts.**

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

## Consequences

Access is granted by changing a binding, and revoked by changing it back. There
is no key to rotate and nothing to leak into a log.

The two accounts must stay asymmetric. Adding a convenience role to
`github-actions-deploy` because one workflow needed it would dissolve the
distinction and hand every application repository the ability to rewrite its
own service.
