data "aws_caller_identity" "current" {}

# Proctoring artifacts bucket
resource "aws_s3_bucket" "proctoring" {
  bucket = "placemux-proctoring-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "proctoring-storage" }
}

# Block ALL public access
resource "aws_s3_bucket_public_access_block" "proctoring" {
  bucket                  = aws_s3_bucket.proctoring.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AES-256 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "proctoring" {
  bucket = aws_s3_bucket.proctoring.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "proctoring" {
  bucket = aws_s3_bucket.proctoring.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policy - move old files to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "proctoring" {
  bucket = aws_s3_bucket.proctoring.id
  rule {
    id     = "archive-old-recordings"
    status = "Enabled"
    filter {}
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}