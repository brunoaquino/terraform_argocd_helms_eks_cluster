output "namespace" {
  description = "Namespace onde o ArgoCD foi instalado"
  value       = local.namespace
}

output "hostname" {
  description = "Hostname do ArgoCD"
  value       = local.argocd_hostname
} 
