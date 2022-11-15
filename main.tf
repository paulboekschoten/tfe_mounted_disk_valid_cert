#terraform settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.38.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.11.1"
    }
  }

  required_version = "1.3.4"
}

# provider settings
provider "aws" {
  region = var.region
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

# resources
# key pair
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key pair
resource "aws_key_pair" "tfe-keypair" {
  key_name   = "${var.environment}-keypair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# store private ssh key locally
resource "local_file" "tfesshkey" {
  content         = tls_private_key.rsa-4096.private_key_pem
  filename        = "${path.module}/tfesshkey.pem"
  file_permission = "0600"
}

# security group
resource "aws_security_group" "tfe_sg" {
  name = "${var.environment}-sg"
}

# sg rule ssh inbound
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule https inbound
resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.https_port
  to_port     = var.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule https inbound
resource "aws_security_group_rule" "allow_replicated_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.replicated_port
  to_port     = var.replicated_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule all outbound
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# create public ip
resource "aws_eip" "eip_tfe" {
  vpc = true
  tags = {
    Name = var.environment
  }
}

# associate public ip with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.tfe.id
  allocation_id = aws_eip.eip_tfe.id
}

## route53 fqdn
# fetch zone
data "aws_route53_zone" "selected" {
  name         = var.route53_zone
  private_zone = false
}

# create record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip_tfe.public_ip]
}

## certficate let's encrypt
# create auth key
resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

# register
resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.cert_private_key.private_key_pem
  email_address   = var.cert_email
}
# get certificate
resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = local.fqdn

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.selected.zone_id
    }
  }
}

# store cert
resource "aws_acm_certificate" "cert" {
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_body  = acme_certificate.certificate.certificate_pem
  certificate_chain = acme_certificate.certificate.issuer_pem
}

# fetch ubuntu ami id for version 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 instance
resource "aws_instance" "tfe" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.tfe-keypair.key_name
  vpc_security_group_ids      = [aws_security_group.tfe_sg.id]

  user_data = templatefile("${path.module}/scripts/user_data.tpl", {
    enc_password        = var.tfe_encryption_password,
    replicated_password = var.replicated_password,
    admin_username      = var.admin_username,
    admin_email         = var.admin_email,
    admin_password      = var.admin_password
    fqdn                = local.fqdn
  })

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name = "${var.environment}-tfe"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa-4096.private_key_pem
    host        = self.public_ip
  }
  
  # copy private key
  provisioner "file" {
    content     = acme_certificate.certificate.private_key_pem
    destination = "/tmp/tfe_server.key"
  }

  # copy full chain
  provisioner "file" {
    content     = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
    destination = "/tmp/tfe_server.crt"
  }

  # copy license
  provisioner "file" {
    source      = "config/license.rli"
    destination = "/tmp/license.rli"
  }
}