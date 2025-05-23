resource "aws_s3_bucket" "db_backups" {
  bucket        = "rogman-tasky-backups"
  force_destroy = true
}

# public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# public read + list
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.db_backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicReadAndList"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.db_backups.bucket}/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.db_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}
