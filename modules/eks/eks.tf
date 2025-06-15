resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster-${var.env}"
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.sg.id]
    subnet_ids              = var.public_subnet_ids
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks]

  tags = {
    Name = "eks-cluster-${var.env}"
  }
}
