
resource "aws_security_group" "mongo_sg" {
  name        = "mongo-sg"
  description = "Allow SSH and MongoDB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.egress_cidr}"]
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  bucket_name = aws_s3_bucket.example.bucket
}




resource "aws_instance" "mongodb" {
  ami           = "ami-0fc5d935ebf8bc3bc" 
  instance_type = "t3.micro"              
  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name



# aws ec2 create-key-pair --key-name my-ec2-keypair \
#     --query "KeyMaterial" --output text > my-ec2-keypair.pem
# latest version of mongodb is 8.0 

  key_name = "my-ec2-key"

  user_data = <<-EOF
#!/bin/bash
apt-get update -y
apt-get install -y gnupg curl awscli cron

curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update -y
apt-get install -y mongodb-org
systemctl enable mongod
systemctl start mongod

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

  tags = {
    Name = "mongodb-ec2"
  }
}


output "public_ip" {
  value = aws_instance.mongodb.public_ip
}

output "ssh_command" {
  value = "ssh -i ${aws_instance.mongodb.key_name}.pem ubuntu@${aws_instance.mongodb.public_ip}"
}
