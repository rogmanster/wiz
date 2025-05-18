output "bucket_name" {
  description = "The name of bucket"
  value       = aws_s3_bucket.db_backups.bucket
}

output "bucket_arn" {
  description = "The ARN of bucket"
  value       = aws_s3_bucket.db_backups.arn
}

output "bucket_url" {
  description = "The public URL"
  value       = "https://${aws_s3_bucket.db_backups.bucket}.s3.amazonaws.com/"
}

