resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = var.coredns_version

  depends_on = [aws_eks_node_group.nodes]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_version

  depends_on = [aws_eks_node_group.nodes]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
  addon_version = var.vpc_cni_version

  depends_on = [aws_eks_node_group.nodes]
}

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name  = aws_eks_cluster.eks.name
#   addon_name    = "ebs-csi-driver"
#   addon_version = var.vpc_cni_version

#   depends_on = [aws_eks_node_group.nodes]
# }
