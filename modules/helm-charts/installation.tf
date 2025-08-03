resource "kubernetes_manifest" "argocd_namespace" {
  manifest = yamldecode(file("${path.module}/manifests/argocd-ns.yaml"))
}

resource "kubernetes_manifest" "argo_workflows_namespace" {
  manifest = yamldecode(file("${path.module}/manifests/argo-workflows-ns.yaml"))
}

resource "kubernetes_manifest" "argo_rollouts_namespace" {
  manifest = yamldecode(file("${path.module}/manifests/argo-rollouts-ns.yaml"))
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_manifest.argocd_namespace.manifest["metadata"]["name"]
  version    = "5.51.6"

  depends_on = [kubernetes_manifest.argocd_namespace]
}

resource "helm_release" "argo_workflows" {
  name = "argo-workflows"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  namespace  = kubernetes_manifest.argo_workflows_namespace.manifest["metadata"]["name"]
  version    = "0.45.19"
  values = [
    file("${path.module}/argo-wf-values.yaml")
  ]

  depends_on = [
  kubernetes_manifest.argo_workflows_namespace]
}

resource "kubernetes_manifest" "argo_wf_sa" {
  manifest = yamldecode(file("${path.module}/manifests/argo-workflows-sa.yaml"))
}

resource "kubernetes_manifest" "argo_wf_role" {
  manifest = yamldecode(file("${path.module}/manifests/argo-workflows-role.yaml"))
}

resource "kubernetes_manifest" "argo_wf_rolebinding" {
  manifest = yamldecode(file("${path.module}/manifests/argo-workflows-rolebinding.yaml"))
}

resource "kubernetes_manifest" "argo_wf_docker_secret" {
  manifest = yamldecode(file("${path.module}/manifests/docker-credentials-secret.yaml"))
}

resource "aws_iam_role" "argo_wf_s3_role" {
  name = "argo-wf-s3-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "argo-wf-s3-role-${var.env}"
  }
}

resource "aws_iam_policy" "argo_wf_s3_policy" {
  name = "argo-wf-s3-policy-${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::argo-wf-artifacts-vv",
          "arn:aws:s3:::argo-wf-artifacts-vv/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argo_wf_s3_role" {
  role       = aws_iam_role.argo_wf_s3_role.name
  policy_arn = aws_iam_policy.argo_wf_s3_policy.arn
}

resource "aws_eks_pod_identity_association" "argo_wf_s3_role" {
  cluster_name    = var.cluster_name
  role_arn        = aws_iam_role.argo_wf_s3_role.arn
  namespace       = "argo-wf"
  service_account = "argo-sa"
}

resource "helm_release" "argo_rollouts" {
  name = "argo-rollouts"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = kubernetes_manifest.argo_rollouts_namespace.manifest["metadata"]["name"]
  version    = "2.40.0"

  depends_on = [kubernetes_manifest.argo_rollouts_namespace]
}
