output "attacker_instance_id" {
  value = aws_instance.attacker.id
}

output "attacker_ip" {
  value = aws_instance.attacker.public_ip
}
