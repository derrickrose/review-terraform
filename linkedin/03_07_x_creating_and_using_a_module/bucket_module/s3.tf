variable "bucket_name" {
  description = "The name of the S3 bucket to create"
}


resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


output "arn" {
    description = "The ARN of the S3 bucket created by this module"
    value       = aws_s3_bucket.bucket.arn
}

