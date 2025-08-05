# EFS CSI Driver IAM Role Trust Policy
data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# EFS CSI Driver IAM Role
resource "aws_iam_role" "efs_csi_driver" {
  name = "eks-efs-csi-driver-${var.env}"

  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json

  tags = merge(
    {
      Name        = "eks-efs-csi-driver-${var.env}"
      Environment = var.env
      ClusterName = var.cluster_name
      Purpose     = "EFS CSI Driver Service Account"
    },
    var.tags
  )
}

# Attach AWS Managed Policy for EFS CSI Driver
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# Custom Policy for EFS CSI Driver Encryption
resource "aws_iam_policy" "efs_csi_driver_encryption" {
  name        = "${var.cluster_name}-efs-csi-driver-encryption-policy-${var.env}"
  description = "Policy for EFS CSI Driver encryption operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.cluster_name}-efs-csi-driver-encryption-policy-${var.env}"
      Environment = var.env
      ClusterName = var.cluster_name
    },
    var.tags
  )
}

# Attach Encryption Policy to EFS CSI Driver Role
resource "aws_iam_role_policy_attachment" "efs_csi_driver_encryption" {
  role       = aws_iam_role.efs_csi_driver.name
  policy_arn = aws_iam_policy.efs_csi_driver_encryption.arn
}

# EKS Pod Identity Association for EFS CSI Driver
resource "aws_eks_pod_identity_association" "efs_csi_driver" {
  cluster_name    = var.cluster_name
  role_arn        = aws_iam_role.efs_csi_driver.arn
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
} 
