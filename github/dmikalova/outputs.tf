output "authenticated_user" {
  description = "The authenticated GitHub user"
  value = {
    login = data.github_user.current.login
    name  = data.github_user.current.name
  }
}

# GitHub's immutable OIDC subjects name the account by id, not login, so any
# stack that trusts this account's workflows needs the number.
output "owner_id" {
  description = "Numeric GitHub account id of the owner"
  value       = data.github_user.current.id
}

output "repositories" {
  description = "All managed repositories"
  value       = module.repositories.repositories
}
