generate "example" {
  contents  = <<EOF
output "generate" {
    value = "generate works"
}
EOF
  if_exists = "overwrite"
  path      = "example.tf"
}
