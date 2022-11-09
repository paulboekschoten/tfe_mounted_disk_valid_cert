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
- Clone this repository.  
```
git clone https://github.com/paulboekschoten/tfe_mounted_disk_valid_cert.git
```

- Go to the directory 
```
cd tfe_mounted_disk_valid_cert
```

- Rename `terraform.tfvars_example` to `terraform.tfvars`.  
```
mv terraform.tfvars_example terraform.tfvars
```
- Change the values in `terraform.tfvars` to your needs.  

- Save your TFE license in `config/license.rli`.  

 - Set your AWS credentials
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
```

- Terraform initialize
```
terraform init
```
- Terraform plan
```
terraform plan
```

- Terraform apply
```
terraform apply
```

Terraform output should show 16 resources to be created with output similar to below. 
```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "15.188.223.44"
replicated_dashboard = "https://tfe-valid-cert-paul-tf.tf-support.hashicorpdemo.com:8800"
ssh_login = "ssh -i tfesshkey.pem ubuntu@tfe-valid-cert-paul-tf.tf-support.hashicorpdemo.com"
tfe_login = "https://tfe-valid-cert-paul-tf.tf-support.hashicorpdemo.com"
```


- Go to the Replicated dashboard. (Can take 10 minutes to become available.)  
- Click on the open button to go to TFE of go to the `tfe_login` url.  

# TODO


# DONE
 - [x] Create manually
 - [x] Create a key pair
 - [x] Create a security group
 - [x] Create a security group rules
 - [x] Create valid certificates
 - [x] Create DNS record
 - [x] Create an EC2 instance
 - [x] Install TFE 
   - [x] Download TFE
   - [x] Create settings.json
   - [x] Create replicated.conf
   - [x] Copy certificates
   - [x] Copy license.rli
   - [x] Create admin user
 - [x] Documentation
