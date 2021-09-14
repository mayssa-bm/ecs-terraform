provider "aws" {
  #access_key = ""
  #secret_key = ""
  region     = var.aws_region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile = "default"
}