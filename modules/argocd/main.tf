resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"      = "argocd"
      "app.kubernetes.io/component" = "server"
    }
  }
}

locals {
  namespace           = var.create_namespace ? kubernetes_namespace.argocd[0].metadata[0].name : var.namespace
  argocd_hostname     = "argocd.${var.base_domain}"
  cert_manager_issuer = var.cert_manager_environment == "staging" ? "letsencrypt-staging" : "letsencrypt-prod"
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = local.namespace

  values = [
    yamlencode({
      global = {
        domain = var.base_domain
      }

      server = {
        extraArgs = [
          "--insecure"
        ]

        service = {
          type = var.service_type
        }

        ingress = {
          enabled = var.create_ingress
          hosts = [
            local.argocd_hostname
          ]
          annotations = {
            "kubernetes.io/ingress.class"                    = "nginx"
            "cert-manager.io/cluster-issuer"                 = local.cert_manager_issuer
            "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "external-dns.alpha.kubernetes.io/hostname"      = local.argocd_hostname
          }
          tls = [{
            secretName = "argocd-server-tls"
            hosts = [
              local.argocd_hostname
            ]
          }]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Cria um ConfigMap com configurações de exemplo para o ArgoCD
resource "kubernetes_config_map" "argocd_cm" {
  metadata {
    name      = "argocd-cm-custom"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "repositories"   = yamlencode(var.repositories)
    "policy.csv"     = var.rbac_policy_csv
    "policy.default" = var.rbac_policy_default
  }

  depends_on = [
    helm_release.argocd
  ]
}

