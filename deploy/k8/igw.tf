resource "aws_internet_gateway" "myvpc-igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myvpc-igw"
  }
}