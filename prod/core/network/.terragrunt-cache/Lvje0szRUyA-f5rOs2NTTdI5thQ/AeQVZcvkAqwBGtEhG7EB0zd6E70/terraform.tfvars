terragrunt = {
  terraform {
    source = "github.com/rafaelmnatali/terraform_modules"
  }
}

aws_region = "eu-west-1"
cidr_block_dev = "10.131.0.0/16"