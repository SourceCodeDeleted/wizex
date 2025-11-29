

locals {
  bucket_name = aws_s3_bucket.mongo_backups.bucket
}

resource "aws_instance" "mongodb" {
  ami                    = var.outdated_linux_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = "my-ec2-key"

  user_data = <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y gnupg curl awscli cron

curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update -y
apt-get install -y mongodb-org
systemctl enable mongod
systemctl start mongod

sleep 10
mongosh admin --eval 'db.createUser({ user: "root", pwd: "example", roles: [ { role: "root", db: "admin" } ] })'

# Create backup script
cat << SCRIPT > /usr/local/bin/mongo_backup.sh
#!/bin/bash

TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR="/tmp/mongo_backup_\$TIMESTAMP"

mongodump --out "\$BACKUP_DIR"
tar -czf "\$BACKUP_DIR.tar.gz" "\$BACKUP_DIR"

aws s3 cp "\$BACKUP_DIR.tar.gz" s3://${local.bucket_name}/mongo-backups/mongo_\$TIMESTAMP.tar.gz

rm -rf "\$BACKUP_DIR" "\$BACKUP_DIR.tar.gz"
SCRIPT

chmod +x /usr/local/bin/mongo_backup.sh

echo "*/5 * * * * root /usr/local/bin/mongo_backup.sh >> /var/log/mongo_backup.log 2>&1" >> /etc/crontab
systemctl restart cron

EOF

  metadata_options {
    http_tokens = "optional" # insecure (allowed for Wiz)
  }

  tags = {
    Name = "mongodb-ec2"
  }
}

output "ssh_command" {
  description = "Command to SSH into the MongoDB instance"
  value       = "ssh -i my-ec2-key.pem ubuntu@${aws_instance.mongodb.public_ip}"
}

output "mongodb_private_ip" {
  description = "Private IP for K8s connection"
  value       = aws_instance.mongodb.private_ip
}

output "mongodb_uri" {
  description = "MongoDB connection URI"
  value       = "mongodb://root:example@${aws_instance.mongodb.private_ip}:27017"
}