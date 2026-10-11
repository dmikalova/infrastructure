# 5. Tofu owns the Cloud Run service, CI owns the image

This decision records the split between the service's shape and the code
running inside it.

## Context

Two systems want to write to the same Cloud Run service. This repository
defines its shape: service account, secrets, scaling, domain mapping,
permissions. The application's own repository pushes a new container image on
every merge.

If both claim the whole resource they fight. A `tofu apply` after a deploy
reverts the service to whatever image the configuration names, and the
application silently rolls back.

## Decision

**The two systems own different fields of the same resource.**

- **Tofu creates the service with `gcr.io/cloudrun/placeholder`.** The service
  must exist before the application's first image does, so creation cannot
  depend on a real image being available.
- **Tofu then ignores the fields CI owns:** the container image, the revision
  name, and the client annotations. They are listed in `ignore_changes`.
- **The deploy service account holds `roles/run.developer`, not
  `roles/run.admin`.** It can ship a new revision. It cannot change the service
  account the service runs as, its secrets, or its ingress.

## Consequences

The permission boundary enforces the ownership split rather than merely
describing it. A compromised application repository can deploy a bad image,
which is bad, but cannot grant itself new secrets or escalate the service's
identity, which would be much worse.

A genuine image change made here does nothing, because the field is ignored.
Changing the deployed version is always an action in the application's
repository.
