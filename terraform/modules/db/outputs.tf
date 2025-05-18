output "mongodb_ip" {
  description = "Public IP of the MongoDB VM"
  value       = aws_instance.mongodb.public_ip
}


