# resource "kubectl_manifest" "gp3_storageclass" {
#   manifest = yamldecode(file("${path.module}/manifests/gp3-storageclass.yaml")

#   )
#   depends_on = [aws_eks_addon.ebs_csi_driver]
# }
