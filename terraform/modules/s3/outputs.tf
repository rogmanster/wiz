output "bucket_name" {
  value       = aws_s3_bucket.db_backups.bucket
}

output "bucket_arn" {
  value       = aws_s3_bucket.db_backups.arn
}

output "bucket_url" {
  value       = "https://${aws_s3_bucket.db_backups.bucket}.s3.amazonaws.com/"
}

