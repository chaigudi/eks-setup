terraform {
  backend "s3" {
    bucket       = "color-page-23112025"
    key          = "eks/prod/cluster/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

