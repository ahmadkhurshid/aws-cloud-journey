terraform {
  backend "s3" {
    bucket       = "tf-state-039324592089"
    key          = "terraform-practice/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}