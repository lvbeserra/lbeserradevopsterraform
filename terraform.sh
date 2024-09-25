#!/bin/bash

# Função para criar o cluster Kind
create_cluster() {
    echo "Criando o cluster Kind..."
    kind create cluster --name projeto-terraform
}

# Função para verificar os serviços no namespace kube-system
check_services() {
    echo "Verificando serviços no namespace kube-system..."
    kubectl get services -n kube-system
}

# Função para aguardar a inicialização completa do cluster
wait_for_initialization() {
    echo "Aguardando a inicialização completa do cluster..."
    while true; do
        if kubectl get pods -n kube-system | grep -q "0/1"; then
            echo "Aguardando todos os pods em kube-system ficarem prontos..."
            sleep 5
        else
            echo "Todos os pods no namespace kube-system estão prontos."
            break
        fi
    done
}

# Função para configurar RBAC para o serviço kube-dns
setup_rbac() {
    echo "Configurando RBAC para o kube-dns..."
    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: kube-system
  name: dns-access
rules:
- apiGroups: [""]
  resources: ["services/proxy"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: allow-anonymous-dns
  namespace: kube-system
subjects:
- kind: Group
  name: system:anonymous
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dns-access
  apiGroup: rbac.authorization.k8s.io
EOF
}

# Função principal
main() {
    create_cluster
    check_services
    wait_for_initialization
    setup_rbac

    echo "Cluster Kind 'projeto-terraform' criado e configurado com sucesso!"
}

# Executar a função principal
main

