# resource "aws_subnet" "public" {
#   vpc_id                  = aws_vpc.myvpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name                         = "public-us-east-1a"
#     "kubernetes.io/role/elb"     = "1"
#     "kubernetes.io/cluster/eks-cluster" = "shared"
#   }
# }


# resource "aws_subnet" "private_a" {
#   vpc_id            = aws_vpc.myvpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name                              = "private-us-east-1a"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/eks-cluster" = "shared"
#   }
# }

# resource "aws_subnet" "private_a" {
#   vpc_id            = aws_vpc.myvpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name                              = "private-us-east-1a"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/eks-cluster" = "shared"
#   }
# }
