############################################
# VPC
############################################
resource "aws_vpc" "wiz" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wiz-vpc"
  }
}

############################################
# Internet Gateway (for public subnet)
############################################
resource "aws_internet_gateway" "wiz_igw" {
  vpc_id = aws_vpc.wiz.id

  tags = {
    Name = "wiz-igw"
  }
}

############################################
# Public Subnet (for MongoDB)
############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.wiz.id
  cidr_block              = "10.0.1.0/24" # mongoDB will go into the public as per document.
  map_public_ip_on_launch = true

  availability_zone = "us-east-1a"

  tags = {
    Name = "wiz-public-subnet"
  }
}

############################################
# Private Subnets (for Kubernetes Cluster)
############################################
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.wiz.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "wiz-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.wiz.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "wiz-private-subnet-b"
  }
}

############################################
# Public Route Table
############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wiz.id

  tags = {
    Name = "wiz-public-rt"
  }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wiz_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# NAT Gateway (OPTIONAL — recommended)
############################################

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "wiz_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "wiz-nat"
  }
}

############################################
# Private Route Table
############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wiz.id

  tags = {
    Name = "wiz-private-rt"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wiz_nat.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

############################################
# Outputs
############################################
output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "k8s_private_subnets" {
  value = [
    aws_subnet.private_a.cidr_block,
    aws_subnet.private_b.cidr_block
  ]
}
