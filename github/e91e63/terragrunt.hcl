include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "e91e63"
    repositories = {
      terraform-digitalocean-account = {
        description      = "Terraform modules for managing Digital Ocean accounts"
        visibility_level = "public"
      },
      terraform-digitalocean-kubernetes = {
        description      = "Terraform modules for deploying a Digital Ocean Kubernetes cluster"
        visibility_level = "public"
      },
      terraform-digitalocean-networking = {
        description      = "Terraform modules for managing Digital Ocean networking resources"
        visibility_level = "public"
      },
      terraform-digitalocean-postgresql = {
        description      = "Terraform modules for managing Digital Ocean PostgreSQL databases"
        visibility_level = "public"
      },
      terraform-digitalocean-spaces = {
        description      = "Terraform modules for Digital Ocean spaces"
        visibility_level = "public"
      },
      terraform-github-repositories = {
        description      = "Terraform modules for managing Github Repositories"
        visibility_level = "public"
      },
      terraform-gitlab-projects = {
        description      = "Terraform modules for managing Gitlab Projects and related resources"
        visibility_level = "public"
      },
      terraform-kubernetes-manifests = {
        description      = "Terraform modules for managing Kubernetes manifests"
        visibility_level = "public"
      },
      terraform-tekton-pipelines = {
        description      = "Terraform modules for building reusable Tekton pipelines"
        visibility_level = "public"
      },
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
