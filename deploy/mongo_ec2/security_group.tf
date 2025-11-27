resource "aws_security_group" "mongo_sg" {
  name        = "mongo-sg"
  description = "Allow SSH and restrict MongoDB"
  vpc_id      = aws_vpc.wiz.id

  # SSH must be PUBLIC (required by Wiz)
  ingress {
    description = "Public SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }

  # MongoDB must be reachable ONLY from Kubernetes private subnets
  ingress {
    description = "MongoDB from K8s only"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.k8s_private_subnets
  }

  egress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}