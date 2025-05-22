output "mongodb_ip" {
  description = "Public IP of the MongoDB VM"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_connection_string" {
  description = "Connection string for the MongoDB instance"
  value       = "mongodb://appuser:app123@${aws_instance.mongodb.public_ip}:27017/go-mongodb"
}

