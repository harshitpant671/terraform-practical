# terraform is a Block used to configure the terraform settings for the module.
# {} this is called as argument in terraform

terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }

    aws = {
      source = "hashicorp/aws"
    }
  }
}

# after that install AWS CLI by using command "terraform init"