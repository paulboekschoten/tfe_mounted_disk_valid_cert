output "public_ip" {
  description = "Public IP of the TFE host."
  value       = aws_eip.eip_tfe.public_ip
}

output "replicated_dashboard" {
  description = "Url for Replicated dashboard."
  value       = "https://${local.fqdn}:8800"
}

output "tfe_login" {
  description = "Url for TFE login."
  value       = "https://${local.fqdn}"
}

output "ssh_login" {
  description = "SSH login command."
  value       = "ssh -i tfesshkey.pem ubuntu@${local.fqdn}"
}

output "release_sequence" {
  description = "Installed release number of TFE."
  value       = var.release_sequence
}