# KMS key to decrypt the S3
resource "aws_kms_key" "s3_decrypt_key" {
  description         = "The KMS key used to encrypt the terraform s3 backend bucket"
  enable_key_rotation = true
  tags = {
    s3_bucket_name = "${var.s3_backend.name}"
  }
}

# Create S3 bucket if it doesn't exist
resource "aws_s3_bucket" "backend" {
  bucket = var.s3_backend.name
}

# Block public access
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable S3 versioning
resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = var.s3_backend.versioning
  }
}

# Encrypt bucket with the KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_decrypt_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
