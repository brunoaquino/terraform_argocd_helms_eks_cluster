aws_region           = "us-east-1"
eks_cluster_name     = "app-cluster"
eks_cluster_endpoint = "https://F91C9D34C29F5A4C781708AA122A342A.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_ca_cert  = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSDU2NUsvejR5Nnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1qZ3hNekU1TlRkYUZ3MHpOVEEwTWpZeE16STBOVGRhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURPK0gvUUoyR3dVVkJKZFJPNXF1MWNPOEM2V2J0RTRCc0JaMERMS09ocUVJNngzLzhoWWdMeGFRR1YKSUIrYmh6TXZHQnduV2wySkhYOHB4N0VLcGdIcGcydjkrZ2prQ0ZRRncwNmhPU3RlL2dnMFNXbmwrUEFINVNyNgpWMXFWbm5uZTVsdnZqbmt5NjlqMU1CWCtPZndtVnhPa0ZaTU5JanJRNWpsRkI2c2NlYnlvYUhSQWlsQmNIVkdSCnRyWFBXQ2lSTUpEQ3RJeVp5K2dGWkZ4emsyMzREMTdLMWgvYjZMUzZzNytPL3BxTnlma0NlOG1nWFRQZVdlRmgKc29kSEVxK3VyeEVNSkZhZFpBYkZKdzBoQ3NtN05ocTkzK2NtRGp0NFZQbzRSWC9vU2w0SFFyRzBBd0FjeXJvUQpnUEpLTVoyazI0cm1Gc2xsZ2d0THpiTFRlajNkQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSeTYybTVSc1pCSktUamJWYml5cmd1RW5KdTR6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQUVlcGZtZU5PRQpzOElyZFg3MHUrNDFaU09XbUdWMUk0YmVPUHQ0TEZkOFU0ekNadzJtV2tMNFFTd2ZSVnRPVXJWSDZZRlVUZ2pOCjltWUhrSCsxNk41OWZuRUJIUS9pSXNzU0pPYUlNdzFLNGluSFBrZjlrMi9vczBSakpGandSUUtLUzJmcklhRXUKVnZmaTM5SmJDYXJ5c3B0VFNya0V2aDJrWlhFaHdpQVZjTnpLVVBJNU13aTc2dmF3SzAzd2NqWWlMRlFLL1lYVgpMbTUrL1MwL2xYRTNqcFk0WnlNUUhaU2VLTWhUTlBSSXZXeCtUcVNlMUp2OUh4czJTRWFMMXZyYm03Tlg1RVByCkJBc3BXSkF0MXlPNVBOaVhNbTFNckhwbGw1SHF3SmRIOVpaeS9JQUIrUmlnZ3ZmRlhlNzM2anlqK0d3N1c2UVcKZVZBd3ZWaUxoSkx2Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"

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
