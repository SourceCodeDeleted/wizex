resource "aws_eks_cluster" "eks" {
  name     = "wiz-eks"
  version  = "1.30"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # EKS control plane + nodes live in private subnets
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]

    # to reach API from your laptop
    endpoint_public_access  = true
    endpoint_private_access = true

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]

  tags = {
    Name = "wiz-eks"
  }
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "EKS cluster API server endpoint"
}

output "eks_cluster_ca" {
  value       = aws_eks_cluster.eks.certificate_authority[0].data
  description = "EKS cluster CA data"
  sensitive   = true
}

output "eks_nodegroup_name" {
  value       = aws_eks_node_group.default.node_group_name
  description = "Managed node group name"
}