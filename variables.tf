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