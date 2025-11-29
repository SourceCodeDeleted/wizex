# Security group for MongoDB EC2 instance
resource "aws_security_group" "mongo_sg" {
  name        = "mongo-sg"
  description = "Allow SSH and restrict MongoDB to K8s only"
  vpc_id      = aws_vpc.main.id

  # SSH must be PUBLIC (required by Wiz - intentional vulnerability)
  ingress {
    description = "Public SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB must be reachable ONLY from Kubernetes private subnets
  ingress {
    description = "MongoDB from K8s private subnets only"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24",  # K8s private subnet A
      "10.0.3.0/24"   # K8s private subnet B
    ]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongo-sg"
  }
}

# Security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "wiz-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic within VPC
  ingress {
    description = "Allow all from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wiz-eks-cluster-sg"
  }
}

# Security group for EKS worker nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "wiz-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic within VPC (includes MongoDB access)
  ingress {
    description = "All traffic from VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "All egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wiz-eks-nodes-sg"
  }
}