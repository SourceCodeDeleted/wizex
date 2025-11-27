# bare minimum requirement of eks

resource "aws_eks_cluster" "eks-cluster" {
  name     = "eks-cluster"
  version = "1.31"
  role_arn = aws_iam_role.krash_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
  }

  //depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}