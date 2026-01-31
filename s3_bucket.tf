# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your preferred AWS region
}

# Generate a unique bucket name to avoid conflicts
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Provision an S3 bucket
resource "aws_s3_bucket" "my_secure_bucket" {
  bucket = "my-secure-app-bucket-${random_string.bucket_suffix.result}" # Unique bucket name

  tags = {
    Environment = "Development"
    Project     = "MyApplication"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.my_secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default encryption (SSE-S3) for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_enabled" {
  bucket = aws_s3_bucket.my_secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # S3-managed encryption keys
    }
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "my_secure_bucket_public_access" {
  bucket = aws_s3_bucket.my_secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output the bucket name and ARN
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.my_secure_bucket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.my_secure_bucket.arn
}
