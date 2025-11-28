###############################################
# Single VPC for both MongoDB and EKS
###############################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wiz-vpc"
  }
}

###############################################
# Internet Gateway
###############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "wiz-igw"
  }
}

###############################################
# Public Subnet (for MongoDB EC2)
###############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "wiz-public-subnet"
    "kubernetes.io/role/elb" = "1"
  }
}

###############################################
# Private Subnet A (EKS nodes)
###############################################
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                              = "wiz-private-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

###############################################
# Private Subnet B (EKS nodes)
###############################################
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                              = "wiz-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

###############################################
# NAT Gateway (for private subnets egress)
###############################################
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "wiz-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "wiz-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

###############################################
# Public Route Table
###############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "wiz-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

###############################################
# Private Route Table (routes through NAT)
###############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "wiz-private-rt"
  }
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

###############################################
# Outputs
###############################################
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet for MongoDB"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  description = "Private subnets for EKS"
}

output "k8s_private_subnets_cidr" {
  value = [
    aws_subnet.private_a.cidr_block,
    aws_subnet.private_b.cidr_block
  ]
  description = "CIDR blocks of K8s private subnets"
}