output "authenticated_user" {
  description = "The authenticated GitHub user"
  value = {
    login = data.github_user.current.login
    name  = data.github_user.current.name
  }
}

output "repositories" {
  description = "All managed repositories"
  value       = module.repositories.repositories
}
