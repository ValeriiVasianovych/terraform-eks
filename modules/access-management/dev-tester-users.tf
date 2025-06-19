resource "aws_iam_user" "tester" {
  name = "tester"
}

resource "aws_iam_user" "programmer" {
  name = "programmer"
}

locals {
  dev_test_users = [
    aws_iam_user.tester,
    aws_iam_user.programmer
  ]
}

resource "aws_iam_group" "dev_test_group" {
  name = "dev-testers"
}

resource "aws_iam_group_membership" "dev_test_membership" {
  name = "dev-test-membership"
  users = local.dev_test_users[*].name
  group = aws_iam_group.dev_test_group.name
}

resource "aws_iam_policy" "dev_test_eks" {
  name = "AmazonEKSDevTestPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "dev_test_eks" {
  group      = aws_iam_group.dev_test_group.name
  policy_arn = aws_iam_policy.dev_test_eks.arn
}

resource "aws_eks_access_entry" "dev_test" {
  for_each          = { for user in local.dev_test_users : user.name => user }
  cluster_name      = var.cluster_name
  principal_arn     = each.value.arn
  kubernetes_groups = ["dev-test"]
}

resource "aws_iam_access_key" "tester" {
  user = aws_iam_user.tester.name
}

resource "aws_iam_access_key" "programmer" {
  user = aws_iam_user.programmer.name
}