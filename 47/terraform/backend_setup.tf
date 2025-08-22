provider "aws" {
  region = "ap-southeast-1" # APAC Singapore region
  profile = "your-sso-profile"
}

# IAM Role for Terraform execution
resource "aws_iam_role" "terraform_execution_role" {
  name = "terraform-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Terraform access
resource "aws_iam_policy" "terraform_access_policy" {
  name = "terraform-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}",
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = "${aws_dynamodb_table.terraform_locks.arn}"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_access_policy" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.terraform_access_policy.arn
}

# Logging bucket to store access logs
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "terraform-logging-bucket"

  # Enable encryption for logs stored in this bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Prevent accidental deletion of the bucket
  lifecycle {
    prevent_destroy = true
  }

  # Add tags for identification and management
  tags = {
    Name        = "terraform-logging-bucket"
    Environment = "shared"
  }
}

# Create an S3 bucket for storing Terraform state files
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket"

  # Enable versioning to keep a history of state files
  versioning {
    enabled = true
  }

  # Prevent accidental deletion of the bucket
  lifecycle {
    prevent_destroy = true
  }

  # Add tags for identification and management
  tags = {
    Name        = "terraform-state-bucket"
    Environment = "shared"
  }

  # Enable encryption for state files stored in this bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Block public access to the bucket
  block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Bucket policy for the Terraform state bucket
resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}",
          "${aws_s3_bucket.terraform_state.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          "AWS": "arn:aws:iam::ACCOUNT_ID:role/terraform-role" # Replace ACCOUNT_ID and role with actual values
        }
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}",
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      }
    ]
  })
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Add tags for identification and management
  tags = {
    Name        = "terraform-locks"
    Environment = "shared"
  }
}

# Steps to Run the Terraform Script:
# 1. Initialize Terraform in your project directory:
#    terraform init
#
# 2. Apply the backend setup configuration to create the S3 bucket and DynamoDB table:
#    terraform apply