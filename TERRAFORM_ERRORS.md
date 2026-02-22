# Errors

## provider not initialized

Error: Inconsistent dependency lock file

The following dependency selections recorded in the lock file are inconsistent with the current configuration:

- provider registry.terraform.io/hashicorp/aws: required by this configuration but no version is selected

To make the initial dependency selections that will initialize the dependency lock file, run:
terraform init

- solution : terraform init

## module not installed

│ Error: Module not installed
│
│ on main.tf line 36:
│ 36: module "web_new_sg" {
│
│ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.

- solution : terraform init
