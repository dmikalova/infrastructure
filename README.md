# Infrastructure

[![maintained by dmikalova](https://img.shields.io/static/v1?&color=ccff90&label=maintained%20by&labelColor=424242&logo=&logoColor=fff&message=dmikalova&&style=flat-square)](https://github.com/dmikalova/infrastructure)
[![terragrunt](https://img.shields.io/static/v1?&color=706BF4&label=%20&labelColor=424242&logo=&logoColor=fff&message=terragrunt&&style=flat-square)](https://terragrunt.gruntwork.io/)
[![sops](https://img.shields.io/static/v1?&color=fff&label=%20&labelColor=424242&logo=sops&logoColor=fff&message=sops&&style=flat-square)](https://github.com/mozilla/sops)

This repo contains [Terragrunt configuration](https://terragrunt.gruntwork.io/) for managing personal infrastructure. This infrastructure is used to deploy and manage web apps. The layout of the repo follows Gruntwork's ["Keep your Terraform code DRY"](https://terragrunt.gruntwork.io/docs/features/keep-your-terraform-code-dry/) document.

Infrastructure modules are organized in the GitHub org [e91e63](https://github.com/e91e63/). Web app code is organized in the GitHub org [cddc39](https://github.com/cddc39).

## Features

- Kubernetes cluster with private container registry on DigitalOcean.
- Domains with Let's Encrypt TLS certificates.
- Service based Traefik ingress routes.
- CI/CD pipeline with Tekton.
- GitHub repos with tag based CI/CD webhooks.
- Encrypted secrets with [SOPS](https://github.com/mozilla/sops) and [Age](https://github.com/FiloSottile/age).
