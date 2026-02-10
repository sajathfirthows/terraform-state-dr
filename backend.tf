terraform {
  backend "s3" {
    bucket       = "tf-state-governance-demo-us-east-1"
    key          = "platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
