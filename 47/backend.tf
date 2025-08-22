# FILE: backend.tf

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "path/to/your/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "your-lock-table"
  }
}