provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.eks_cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
  }
}

# Módulo ArgoCD
module "argocd" {
  source = "./modules/argocd"

  aws_region           = var.aws_region
  eks_cluster_name     = var.eks_cluster_name
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_cluster_ca_cert  = var.eks_cluster_ca_cert
  base_domain          = var.base_domain

  # Configurações específicas do ArgoCD
  namespace                = var.argocd_namespace
  create_namespace         = var.argocd_create_namespace
  chart_version            = var.argocd_chart_version
  service_type             = var.argocd_service_type
  enable_https             = var.argocd_enable_https
  create_ingress           = var.argocd_create_ingress
  cert_manager_environment = var.cert_manager_letsencrypt_server
}
