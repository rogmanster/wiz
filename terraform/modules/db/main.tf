resource "aws_key_pair" "mongo_key" {
  key_name   = "mongo-key"
  #public_key = file("~/.ssh/roger-aidemo.pub")
  public_key = var.public_key
}

resource "aws_security_group" "mongo_sg" {
  name        = "mongo-sg"
  description = "Allow SSH and MongoDB"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
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

resource "aws_iam_role" "mongo_role" {
  name = "mongo-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_admin" {
  role       = aws_iam_role.mongo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "mongo_profile" {
  name = "mongo-profile"
  role = aws_iam_role.mongo_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "mongodb" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  key_name                    = aws_key_pair.mongo_key.key_name
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.mongo_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
set -eux

# Install dependencies
apt update -y
apt install -y gnupg curl

# Add MongoDB 5.0 repo key and list
curl -fsSL https://pgp.mongodb.com/server-5.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-5.0.gpg
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/5.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-5.0.list

# Install MongoDB
apt update -y
apt install -y mongodb-org

# Adjust config to allow external connections
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Ensure ownership
chown -R mongodb:mongodb /var/lib/mongodb
chown -R mongodb:mongodb /var/log/mongodb

# Start MongoDB
systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to be ready
until mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "Waiting for mongod to be ready..."
  sleep 2
done

# Create users before enabling authentication
mongosh <<EOM
use admin
db.createUser({
  user: "admin",
  pwd: "admin123",
  roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
})

use go-mongodb
db.createUser({
  user: "appuser",
  pwd: "app123",
  roles: [ { role: "readWrite", db: "go-mongodb" } ]
})
EOM

# Enable authentication in mongod.conf
if ! grep -q "^security:" /etc/mongod.conf; then
  echo -e "\nsecurity:\n  authorization: enabled" >> /etc/mongod.conf
else
  sed -i '/^security:/a\  authorization: enabled' /etc/mongod.conf
fi

# Restart MongoDB to apply auth
systemctl restart mongod

EOF

  tags = {
    Name = "mongodb-vm"
  }
}

