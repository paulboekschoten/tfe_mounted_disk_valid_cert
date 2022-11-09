# Terraform Enterprise installation with valid certificates on AWS  
This repository installs Terraform Enterprise (TFE) with valid certificates in AWS on a Ubuntu virtual machine.  

This terraform code creates
 - A key pair
 - A security group
 - An Ubuntu virtual machine (22.04)
   - Valid certificates
   - Replicated configuration
   - TFE settings json
   - Install latest TFE
   - TFE Admin account


# Prerequisites
 - An AWS account with default VPC and internet access.
 - A TFE license

# How to install TFE with valid certficates on AWS

# TODO
 - [x] Create a key pair
 - [x] Create a security group
 - [x] Create a security group rules
 - [ ] Create valid certificates
 - [ ] Create an EC2 instance
 - [ ] Install TFE 
   - [ ] Download TFE
   - [ ] Create settings.json
   - [ ] Create replicated.conf
   - [ ] Copy certificates
   - [ ] Copy license.rli
   - [ ] Create admin user
 - [ ] Documentation

# DONE
 - [x] Create manually
