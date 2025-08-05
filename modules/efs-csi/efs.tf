# EFS File System
resource "aws_efs_file_system" "eks" {
  creation_token   = "eks"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = merge(
    {
      Name        = "${var.cluster_name}-efs-${var.env}"
      Environment = var.env
      ClusterName = var.cluster_name
      Purpose     = "EKS Persistent Storage"
    },
    var.tags
  )
}

# EFS Mount Targets
resource "aws_efs_mount_target" "efs_mount_target" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = each.value
  security_groups = [var.cluster_security_group_id]
}

# EFS CSI Driver via EKS Addon
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.efs_csi_version
  service_account_role_arn = aws_iam_role.efs_csi_driver.arn

  depends_on = [
    aws_efs_mount_target.efs_mount_target
  ]
}

# EFS Storage Class
resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [aws_eks_addon.efs_csi_driver]
}
