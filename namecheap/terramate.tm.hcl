# Namecheap stacks - generate Terraform config using centralized provider versions

generate_hcl "_terraform.tf" {
  content {
    terraform {
      required_version = ">= 1.8"

      backend "gcs" {
        bucket = global.state_bucket
        prefix = "tfstate/${terramate.stack.path.relative}"
      }

      required_providers {
        namecheap = {
          source  = "namecheap/namecheap"
          version = global.provider_versions.namecheap
        }
        sops = {
          source  = "nobbs/sops"
          version = global.provider_versions.sops
        }
      }
    }

    locals {
      modules_dir  = "${local.repo_root}/terraform/modules"
      repo_root    = tm_replace(terramate.root.path.fs.absolute, "\\", "/")
      state_bucket = global.state_bucket
    }

    provider "namecheap" {
      api_key   = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_API_KEY
      api_user  = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_USER_NAME
      user_name = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_USER_NAME
    }

    provider "sops" {}
  }
}
