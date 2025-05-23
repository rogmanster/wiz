resource "aws_key_pair" "attack_key" {
  key_name   = "attack-key"
  public_key = var.public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "attacker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.attacker_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.attack_key.key_name     

  user_data = <<-EOF
    #!/bin/bash
    set -eux
  
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y -q nmap
  
    # Basic scan
    nmap -Pn -T4 -p 1-1000 ${var.mongodb_ip}
  
    # Add some randomized scans
    for i in {1..5}; do
      nmap -Pn -T4 -p $((RANDOM % 65535)) ${var.mongodb_ip}
      sleep 5
    done

    # Trigger malware detection (EICAR test file)
    curl -O https://secure.eicar.org/eicar.com || true

    # Trigger threat intel alert (Tor check page)
    curl https://check.torproject.org/ || true
  
  EOF

  tags = {
    Name = "guardduty-attack-simulator"
  }
}

resource "aws_security_group" "attacker_sg" {
  name        = "attacker-sg"
  description = "SG for simulated attacker"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


