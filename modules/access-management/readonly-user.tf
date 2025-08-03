# IAM роль для read-only доступа к EKS
resource "aws_iam_role" "eks_readonly" {
  name = "eks-readonly-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root" # Allow all users and roles in the account to assume this role
          # For security, we restrict this to a specific user
        #   AWS = "arn:aws:iam::${var.account_id}:user/readonly-user" # Only allow the specific user to assume this role
        }
      }
    ]
  })
  max_session_duration = 43200
}

# Политика для read-only доступа к EKS
resource "aws_iam_policy" "eks_readonly" {
  name = "AmazonEKSReadOnlyPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:Describe*",
          "eks:List*",
          "eks:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Привязка политики к роли
resource "aws_iam_role_policy_attachment" "eks_readonly" {
  role       = aws_iam_role.eks_readonly.name
  policy_arn = aws_iam_policy.eks_readonly.arn
}

# Создание IAM пользователя
resource "aws_iam_user" "readonly_user" {
  name = "readonly-user"
}

# resource "aws_iam_user" "readonly_user_exp" {
#   name = "readonly-user-exp"
# }

# Политика для возможности assume роли (user can try to assume the role)
resource "aws_iam_policy" "eks_assume_readonly" {
  name = "AmazonEKSAssumeReadOnlyPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = "${aws_iam_role.eks_readonly.arn}"
      }
    ]
  })
}

# Привязка политики assume к пользователю
resource "aws_iam_user_policy_attachment" "readonly_user" {
  user       = aws_iam_user.readonly_user.name
  policy_arn = aws_iam_policy.eks_assume_readonly.arn
}

# resource "aws_iam_user_policy_attachment" "readonly_user_exp" {
#   user       = aws_iam_user.readonly_user_exp.name
#   policy_arn = aws_iam_policy.eks_assume_readonly.arn
# }

# EKS access entry для read-only пользователя
resource "aws_eks_access_entry" "readonly_user" {
  cluster_name      = var.cluster_name
  principal_arn     = aws_iam_role.eks_readonly.arn
  kubernetes_groups = ["viewer"]
}

# Создание access key для пользователя
resource "aws_iam_access_key" "readonly_user" {
  user = aws_iam_user.readonly_user.name
}

# resource "aws_iam_access_key" "readonly_user_exp" {
#   user = aws_iam_user.readonly_user_exp.name
# }