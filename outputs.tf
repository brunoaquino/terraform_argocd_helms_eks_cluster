# Outputs do ArgoCD
output "argocd_namespace" {
  description = "Namespace onde o ArgoCD foi instalado"
  value       = module.argocd.namespace
}

output "argocd_endpoint" {
  description = "Endpoint do ArgoCD"
  value       = "Para acessar o ArgoCD, use: https://argocd.${var.base_domain}"
}

output "argocd_credentials" {
  description = "Instruções para obter as credenciais do ArgoCD"
  value       = <<-EOT
    1. Para obter a senha do administrador inicial:
       kubectl -n ${module.argocd.namespace} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    2. O usuário padrão é: admin
  EOT
}

# Informações gerais
output "info_message" {
  description = "Informações gerais sobre a instalação"
  value       = <<-EOT
    ArgoCD foi instalado com sucesso!
    
    ArgoCD:
    - Namespace: ${module.argocd.namespace}
    - GUI: https://argocd.${var.base_domain}
    
    Observações:
    - Use as instruções acima para obter a senha do administrador inicial
    - Recomenda-se alterar a senha após o primeiro login
    - Configure seus repositórios Git no ArgoCD para gerenciar aplicações
  EOT
}
