aws_region           = "us-east-1"
eks_cluster_name     = "app-cluster"
eks_cluster_endpoint = "https://4E2E57E93AF9A2622E28F5A6371664AC.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_ca_cert  = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUEtFTGNxQ1dBKzB3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMU1ETXhNakF5TWpaYUZ3MHpOVEExTURFeE1qQTNNalphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURPTk1oNlJoTkl5ZlROaFMya3ZvblduNEMyNHRJbmlXS1l6dE5EKzI1SXZ6MWpqajZwODU5VmJ1YmcKY3oyZXFibGo5OGdablNXTWRBbGhEQmdBOTFtOHZYZWVNSVFrTWRjU3VSL3FTeXFzYXM0akRVcTY4aktuczViQwplQnNsRThOSFlacGcyaTRKdUdHQmtld1VxM3RyQjgwdzJMaGU4OHJHNXhDZVNLNWlCeUlLVDNHbDhXWG4zd1R5Cjg5TXRhblN6Vldhblc2eTNmZGN2VHU2WW9TSXR2UmREeVc4ejlRb3NGT3drdGNZc3pJSDk2WXA1UUFuMTB6VjUKM2tlVXk2b1lTcnpKbTVqTUZ2Y3RYUmRWQjVCY1dGOGtBRjVjazRORDF4c2RHaEtsYkVSdWxtS2FEM0E3SGlxdQpUWnF6S3l5N0NMMEpnZEVCei9mZ0xFbldTNW5sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTSXpXQm1vZzJrZlF2T2l2U2lEUWVnOWNnM1dEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzk5ZlZ3VlNjOAppMkM4ZXd5bUJBUVFDQWsyNTRKTkt4T2Y0ei9jV3NHWHRHWnlxK044eDNiYnRaUGd5NDB2bk5OUW85U0lCMGxBCjJORmJBOG83K3gwNGZpUXhEbVBCbGxaYk03VklPazhxTHFtT0ZrSWdnNkpVOTl4bG84WUdaRUpkYWRyTmgwaEYKRkJnVEExdllxRVh2VTkzMDlWUmNUYXYydGdsY1UxZG1UTmRtbGdDb2RseXR5V0V2V3pLcFkwejRuNTdPUUlWLwoxTUMwNUxpbFJ1QlZGMTBkcEJkeWZrdWdXYm5YdSt4WlRiWmpSYWtldVh0bkpmc1lvMFk2WXl0TFNCdDZXZkEwCkxFMmRkNDJoUEU3M2VWc3lOa2xJNEpGV1BHNjZ1dHJrOWVzUHY4aG1xaHFKRElQbzhMUVhieDVuWUR4M0Y3ZXoKVldTa1dJZnZHNkF4Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"

# Domínio Base
base_domain = "mixnarede.com.br"

# Referência ao Cert-Manager já instalado
cert_manager_letsencrypt_server = "prod"

# ArgoCD
argocd_namespace        = "argocd"
argocd_create_namespace = true
argocd_chart_version    = "5.51.4"
argocd_service_type     = "ClusterIP"
argocd_enable_https     = true
argocd_create_ingress   = true

# ArgoCD RBAC
rbac_policy_csv = <<-EOF
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

rbac_policy_default = "role:readonly"

# ArgoCD Repositories
repositories = [
  {
    url  = "https://github.com/exemplo/repositorio.git"
    type = "git"
    name = "exemplo-repo"
  },
  {
    url  = "https://github.com/exemplo/outro-repositorio.git"
    type = "git"
    name = "outro-repo"
  }
]

# ArgoCD Recursos
server_resources = {
  limits = {
    cpu    = "200m"
    memory = "256Mi"
  }
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

repo_server_resources = {
  limits = {
    cpu    = "100m"
    memory = "128Mi"
  }
  requests = {
    cpu    = "50m"
    memory = "64Mi"
  }
}

application_controller_resources = {
  limits = {
    cpu    = "300m"
    memory = "512Mi"
  }
  requests = {
    cpu    = "150m"
    memory = "256Mi"
  }
}
