# Supabase project for mklv
#
# Creates the base Supabase project and stores connection details
# in Secret Manager for use by app stacks.

locals {
  supabase_org_id = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data.SUPABASE_ORG_ID
}

module "supabase_project" {
  source = "${local.modules_dir}/supabase/project"

  gcp_project_id  = local.project_id
  name            = "mklv"
  organization_id = local.supabase_org_id
  supabase_region = "us-west-2"
}
