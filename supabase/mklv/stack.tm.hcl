# Stack definition for mklv Supabase project
stack {
  name        = "mklv-supabase"
  description = "Supabase project and admin credentials for mklv"
  id          = "supabase-mklv"
  tags        = ["google", "sops", "supabase"]

  after = ["/gcp/infra/baseline"]
}
