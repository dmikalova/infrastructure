stack {
  name        = "den Backup Bucket"
  description = "The offsite repository kopia writes to, and the bucket-scoped key that reaches it"
  id          = "backblaze-den-backup"
  tags        = ["backblaze", "den", "sops"]
}
