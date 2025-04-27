# ArgoCD no EKS - Arquitetura de Referência

Este projeto Terraform configura o ArgoCD em um cluster Amazon EKS, permitindo a implementação de GitOps para gerenciar suas aplicações Kubernetes.

## Pré-requisitos

- AWS CLI configurado com acesso adequado
- Terraform >= 1.0.0
- kubectl >= 1.20
- Cluster EKS existente
- Helm >= 3.0.0
- Domínio configurado com Route53 ou outro provedor DNS
- NGINX Ingress Controller já instalado no cluster
- cert-manager com ClusterIssuer letsencrypt-prod já configurado
- External-DNS já configurado

## Dependências de Versões

- ArgoCD Chart: 5.51.4
- cert-manager: v1.10.0 ou superior (já instalado)
- NGINX Ingress Controller: v1.5.0 ou superior (já instalado)
- External-DNS: v0.12.0 ou superior (já instalado)

## Configuração do Ambiente

### 1. Configurar acesso ao cluster EKS

```bash
# Obter credenciais para o cluster EKS
aws eks update-kubeconfig --region us-east-1 --name seu-cluster-eks

# Verificar conexão com o cluster
kubectl cluster-info

# Verificar os componentes já instalados
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get clusterissuer letsencrypt-prod
kubectl get pods -n kube-system -l app.kubernetes.io/name=external-dns
```

## Configuração do Terraform

### 1. Configurar Variáveis

Edite o arquivo `terraform.tfvars` com suas informações:

```hcl
aws_region           = "us-east-1"
eks_cluster_name     = "seu-cluster-eks"
eks_cluster_endpoint = "https://seu-endpoint-eks.region.eks.amazonaws.com"
eks_cluster_ca_cert  = "seu-certificado-ca-base64"

# Obtenha o endpoint e certificado CA com esses comandos:
# aws eks describe-cluster --name seu-cluster-eks --query "cluster.endpoint" --output text
# aws eks describe-cluster --name seu-cluster-eks --query "cluster.certificateAuthority.data" --output text

base_domain = "seu-dominio.com"
cert_manager_letsencrypt_server = "prod"

# ArgoCD
argocd_namespace        = "argocd"
argocd_create_namespace = true
argocd_chart_version    = "5.51.4"
argocd_service_type     = "ClusterIP"
argocd_enable_https     = true
argocd_create_ingress   = true
```

### 2. Inicializar e Aplicar o Terraform

```bash
terraform init
terraform apply
```

## Acesso ao ArgoCD

### Interface Web do ArgoCD

Após a instalação, acesse o ArgoCD através da URL:

```
https://argocd.seu-dominio.com
```

### Obtendo a senha inicial de administrador

A instalação do ArgoCD cria automaticamente um usuário `admin` com uma senha aleatória. Para obter essa senha, execute:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Recomenda-se alterar essa senha após o primeiro login.

## Gerenciamento de Usuários no ArgoCD

### 1. Alterando a senha do administrador

Após fazer login pela primeira vez, recomenda-se alterar a senha do administrador:

1. Faça login na interface web do ArgoCD
2. Clique no ícone de usuário no canto superior direito
3. Selecione "User Info"
4. Clique em "Update Password"
5. Digite a senha atual e depois a nova senha

### 2. Configuração de Autenticação

O ArgoCD suporta várias formas de autenticação. A seguir, apresentamos algumas opções:

#### 2.1. Usando Contas Locais

Para criar usuários locais adicionais, modifique o ConfigMap `argocd-cm`:

```bash
kubectl -n argocd edit configmap argocd-cm
```

Adicione uma seção como esta:

```yaml
data:
  # ... outras configurações existentes

  # Adicionar usuários locais
  accounts.joao: apiKey, login
  accounts.maria: apiKey, login
```

Para definir uma senha para esses usuários:

```bash
# Para o usuário João
argocd account update-password --account joao --current-password <senha-admin> --new-password <nova-senha>

# Para usuários que ainda não possuem senha definida
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"accounts.joao.password": "$2a$10$mivhwHQZE9jlIKlo3pCGvOU6CWwIqJ2YH4Qo/sRnro9IvQCNQbJt6"}}'
# A senha acima é um hash BCrypt para "senha123" - substitua por um hash válido
```

#### 2.2. Integração com OIDC (por exemplo, Google, GitHub, Okta)

Para configurar OIDC, adicione ao ConfigMap `argocd-cm`:

```yaml
data:
  # ... outras configurações existentes

  url: https://argocd.seu-dominio.com

  # Configurações OIDC para GitHub
  oidc.config: |
    name: GitHub
    issuer: https://api.github.com/
    clientID: seu-client-id
    clientSecret: $dex.github.clientSecret
    requestedScopes: ["openid", "profile", "email"]
```

E no Secret `argocd-secret`:

```yaml
stringData:
  # ... outras configurações existentes

  dex.github.clientSecret: seu-client-secret
```

#### 2.3. Integração com LDAP

Para configurar LDAP, modifique o ConfigMap `argocd-cm`:

```yaml
data:
  # ... outras configurações existentes

  url: https://argocd.seu-dominio.com

  # Configurações LDAP
  dex.config: |
    connectors:
      - type: ldap
        name: ActiveDirectory
        id: activedirectory
        config:
          host: ldap.exemplo.com:389
          insecureNoSSL: false
          insecureSkipVerify: true
          bindDN: cn=serviceaccount,dc=example,dc=com
          bindPW: $dex.ldap.bindPW
          userSearch:
            baseDN: ou=users,dc=example,dc=com
            filter: (objectClass=person)
            username: sAMAccountName
            idAttr: sAMAccountName
            emailAttr: mail
            nameAttr: displayName
          groupSearch:
            baseDN: ou=groups,dc=example,dc=com
            filter: (objectClass=group)
            userAttr: DN
            groupAttr: member
            nameAttr: cn
```

E no Secret `argocd-secret`:

```yaml
stringData:
  # ... outras configurações existentes

  dex.ldap.bindPW: sua-senha-ldap
```

### 3. Gerenciamento de Permissões (RBAC)

O ArgoCD usa Kubernetes RBAC para gerenciar permissões. Configure políticas editando o ConfigMap `argocd-rbac-cm`:

```bash
kubectl -n argocd edit configmap argocd-rbac-cm
```

Adicione a configuração:

```yaml
data:
  policy.csv: |
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

  policy.default: role:readonly
```

Após fazer essas alterações, reinicie o servidor do ArgoCD:

```bash
kubectl -n argocd rollout restart deployment argocd-server
```

## Configurando Repositórios Git

### 1. Repositórios privados HTTPS com credenciais

```bash
argocd repo add https://github.com/sua-org/seu-repo.git --username seu-usuario --password sua-senha
```

### 2. Repositórios privados com SSH

Primeiro, crie um Secret com sua chave SSH:

```bash
kubectl -n argocd create secret generic git-ssh-key \
  --from-file=sshPrivateKey=$HOME/.ssh/id_rsa
```

Depois adicione o repositório:

```bash
argocd repo add git@github.com:sua-org/seu-repo.git --ssh-private-key-path /tmp/ssh-key
```

### 3. Usando a interface Web

Você também pode adicionar repositórios via interface web:

1. Faça login em https://argocd.seu-dominio.com
2. Navegue até "Settings" > "Repositories"
3. Clique em "Connect Repo"
4. Preencha os dados do repositório e salve

## Solução de Problemas

### Problemas com Certificados

Se os certificados não forem emitidos automaticamente:

```bash
# Verificar status dos certificados
kubectl get certificate -n argocd

# Verificar status dos CertificateRequests
kubectl get certificaterequest -n argocd

# Verificar logs do cert-manager
kubectl logs -n cert-manager -l app=cert-manager
```

### Problemas com o ArgoCD

```bash
# Verificar logs do ArgoCD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Reiniciar componentes do ArgoCD
kubectl rollout restart deployment -n argocd argocd-server
kubectl rollout restart deployment -n argocd argocd-repo-server
kubectl rollout restart deployment -n argocd argocd-application-controller
```

### Problemas de Acesso

Se houver problemas para acessar a interface web:

```bash
# Verificar se o ingress está configurado corretamente
kubectl get ingress -n argocd

# Verificar se o serviço está funcionando
kubectl get svc -n argocd

# Verificar se o pod está em execução
kubectl get pods -n argocd

# Para acesso temporário via port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Depois acesse em localhost:8080
```
