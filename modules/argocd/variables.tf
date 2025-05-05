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

variable "repositories" {
  description = "Lista de repositórios Git para o ArgoCD"
  type = list(object({
    url  = string
    type = string
    name = string
  }))
  default = []
}

variable "rbac_policy_csv" {
  description = "Configuração RBAC do ArgoCD em formato CSV"
  type        = string
  default     = <<-EOF
    # Permissão admin padrão
    p, role:admin, *, *, *, allow

    # Criar papel de apenas-leitura
    p, role:readonly, applications, get, */*, allow
    p, role:readonly, clusters, get, *, allow
    p, role:readonly, repositories, get, *, allow
    p, role:readonly, projects, get, *, allow

    # Criar papel de desenvolvedor
    p, role:developer, applications, create, */*, allow
    p, role:developer, applications, update, */*, allow
    p, role:developer, applications, get, */*, allow

    # Atribuir papéis aos usuários
    g, joao, role:developer
    g, maria, role:readonly

    # Atribuir papel de administrador a usuários específicos
    g, admin, role:admin
  EOF
}

variable "rbac_policy_default" {
  description = "Política padrão para novos usuários"
  type        = string
  default     = "role:readonly"
}

# Recursos e limites
variable "server_resources" {
  description = "Recursos para o servidor ArgoCD"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "300m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
  }
}

variable "repo_server_resources" {
  description = "Recursos para o repo-server do ArgoCD"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "300m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
  }
}

variable "application_controller_resources" {
  description = "Recursos para o application-controller do ArgoCD"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}
