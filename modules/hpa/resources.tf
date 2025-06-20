# resource "kubernetes_manifest" "app_namespace" {
#   manifest   = yamldecode(file("${path.module}/hpa-manifests/namespace.yaml"))
#   depends_on = [helm_release.metrics_server]
# }

# resource "kubernetes_manifest" "app_deployment" {
#   manifest   = yamldecode(file("${path.module}/hpa-manifests/deployment.yaml"))
#   depends_on = [kubernetes_manifest.app_namespace]
# }

# resource "kubernetes_manifest" "app_service" {
#   manifest   = yamldecode(file("${path.module}/hpa-manifests/service.yaml"))
#   depends_on = [kubernetes_manifest.app_deployment]
# }

# resource "kubernetes_manifest" "app_hpa" {
#   manifest   = yamldecode(file("${path.module}/hpa-manifests/hpa.yaml"))
#   depends_on = [kubernetes_manifest.app_service]
# }
