terraform {
  backend "s3" {
    bucket       = "terraform-remote-backend-720277889761-ap-south-1-an"
    key          = "eks-learning/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}