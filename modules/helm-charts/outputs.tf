output "argocd_release_name" {
  description = "The name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "argocd_status" {
  description = "The status of the ArgoCD Helm release"
  value       = helm_release.argocd.status
}

output "argo_workflows_release_name" {
  description = "The name of the Argo Workflows Helm release"
  value       = helm_release.argo_workflows.name
}

output "argo_workflows_status" {
  description = "The status of the Argo Workflows Helm release"
  value       = helm_release.argo_workflows.status
}
