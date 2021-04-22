This directory contains the local terraform configuration. AWS and Terraform CLI must be installed and configured.


Steps to create infrastructure:

terraform init
terraform plan -out=build.pln
terraform apply build.pln


Steps to destroy infrastructure:

terraform plan -destroy -out=destroy.pln
terraform apply destroy.pln