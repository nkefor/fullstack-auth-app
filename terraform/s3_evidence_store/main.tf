# main.tf - Defines the AWS S3 bucket for storing immutable audit evidence.

resource "aws_s3_bucket" "evidence_store" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = "Unified Compliance"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "evidence_store_versioning" {
  bucket = aws_s3_bucket.evidence_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "evidence_store_encryption" {
  bucket = aws_s3_bucket.evidence_store.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "evidence_store_public_access" {
  bucket = aws_s3_bucket.evidence_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "evidence_store_policy" {
  bucket = aws_s3_bucket.evidence_store.id
  policy = data.aws_iam_policy_document.evidence_store_policy_doc.json
}

# This policy enforces that no one can delete objects, ensuring immutability.
# It allows for a specific role (e.g., from a CI/CD pipeline) to put objects in the bucket.
data "aws_iam_policy_document" "evidence_store_policy_doc" {
  statement {
    sid = "AllowWriteOnceReadMany"
    principals {
      type        = "AWS"
      identifiers = [var.cicd_pipeline_role_arn]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.evidence_store.arn}/*"
    ]
  }

  statement {
    sid    = "DenyDelete"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.evidence_store.arn}/*"
    ]
  }
}
