terraform {
  backend "s3" {
    bucket       = "your-tfstate-bucket-name"
    key          = "eks-learning/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}