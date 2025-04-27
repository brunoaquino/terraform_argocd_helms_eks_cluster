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

variable "namespace" {
  description = "Namespace do Kubernetes onde o ArgoCD será instalado"
  type        = string
  default     = "argocd"
}

variable "create_namespace" {
  description = "Indica se deve criar o namespace para o ArgoCD"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão do Helm chart do ArgoCD"
  type        = string
  default     = "5.51.4"
}

variable "service_type" {
  description = "Tipo de serviço para o ArgoCD (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "enable_https" {
  description = "Habilita HTTPS para o ArgoCD"
  type        = bool
  default     = true
}

variable "create_ingress" {
  description = "Indica se deve criar um Ingress para o ArgoCD"
  type        = bool
  default     = true
}

variable "cert_manager_environment" {
  description = "Ambiente do Cert-Manager a ser usado (staging ou prod)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "prod"], var.cert_manager_environment)
    error_message = "O valor de cert_manager_environment deve ser 'staging' ou 'prod'."
  }
}
