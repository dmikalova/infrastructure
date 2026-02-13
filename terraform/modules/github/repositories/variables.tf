variable "owner" {
  description = "GitHub owner (user or organization) for these repositories"
  type        = string
}

variable "repositories" {
  description = "Map of repository names to their configuration"
  type = map(object({
    description = optional(string, "")
    topics      = optional(list(string), [])
    visibility  = optional(string, "public")
  }))
}
