variable "region" {
  description = "Region to deploy infrastructure in."
  type        = string
}

variable "environment" {
  description = "Name of the environent, used in creation of resources."
  type        = string
}

variable "ssh_port" {
  description = "Server port for SSH requests."
  type        = number
  default     = 22
}

variable "https_port" {
  description = "Server port for HTTPS requests."
  type        = number
  default     = 443
}

variable "replicated_port" {
  description = "Server port for Replicated dashboard."
  type        = number
  default     = 8800
}

variable "cert_email" {
  description = "Email address used to obtain ssl certificate."
  type        = string
}

variable "route53_zone" {
  description = "The domain used in the URL."
  type        = string
}

variable "route53_subdomain" {
  description = "the subdomain of the url"
  type        = string
}