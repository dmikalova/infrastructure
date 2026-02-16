variable "domain" {
  description = "Domain name to manage"
  type        = string
}

variable "nameservers" {
  description = "Custom nameservers for the domain"
  type        = list(string)
}
