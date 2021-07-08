#!/bin/bash

echo "Create resource role"
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN="s.VQsR0ahXDL7CmiYcYf0k0wXe"

echo "Create k8s resource"
vault auth enable kubernetes 2>&1 >/dev/null

echo "Get K8s SA name"
export VAULT_SA_NAME=$(kubectl get sa vault-reviewer \
    -o jsonpath="{.secrets[*]['name']}")

echo "Get K8s SA JWT token"
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME \
    -o jsonpath="{.data.token}" | base64 --decode; echo)
echo "SA_JWT_TOKEN: $SA_JWT_TOKEN"

echo "Get K8s SA CA CRT"
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME \
    -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

echo "Vault update K8s config"
vault write auth/kubernetes/config \
    token_reviewer_jwt="$SA_JWT_TOKEN" \
    kubernetes_host="https://45.32.124.125:6443" \
    kubernetes_ca_cert="$SA_CA_CRT"

echo "Vault create K8s role"
vault write auth/kubernetes/role/vault-test \
        bound_service_account_names=vault-reviewer \
        bound_service_account_namespaces=org1-net \
        policies=vault-crypto-org-org1-net-ro \
        ttl=24h

curl -sS --request POST http://45.32.124.125:8200/v1/auth/kubernetes/login \
  -H "Content-Type: application/json" \
  -d '{"role":"vault-test","jwt":"'"$SA_JWT_TOKEN"'"}'
