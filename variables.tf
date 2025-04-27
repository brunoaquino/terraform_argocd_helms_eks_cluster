variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  type        = string
}

variable "eks_cluster_ca_cert" {
  description = "Certificado CA do cluster EKS"
  type        = string
}

variable "base_domain" {
  description = "Nome de domínio base para o qual o External-DNS terá permissões"
  type        = string
}

# Referência ao Cert-Manager já instalado no cluster
variable "cert_manager_letsencrypt_server" {
  description = "Servidor do Let's Encrypt (staging ou prod)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "prod"], var.cert_manager_letsencrypt_server)
    error_message = "O valor de cert_manager_letsencrypt_server deve ser 'staging' ou 'prod'."
  }
}

# Variáveis para o módulo ArgoCD
variable "argocd_namespace" {
  description = "Namespace do Kubernetes onde o ArgoCD será instalado"
  type        = string
  default     = "argocd"
}

variable "argocd_create_namespace" {
  description = "Indica se deve criar o namespace para o ArgoCD"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "Versão do Helm chart do ArgoCD"
  type        = string
  default     = "5.51.4"
}

variable "argocd_service_type" {
  description = "Tipo de serviço para o ArgoCD (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_enable_https" {
  description = "Habilita HTTPS para o ArgoCD"
  type        = bool
  default     = true
}

variable "argocd_create_ingress" {
  description = "Indica se deve criar um Ingress para o ArgoCD"
  type        = bool
  default     = true
}
