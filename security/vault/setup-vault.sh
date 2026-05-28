#!/bin/bash
# Vault setup script - run after vault is initialized

set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-https://vault.internal.company.com:8200}"

echo ">>> Enabling secrets engines..."
vault secrets enable -path=secret kv-v2
vault secrets enable -path=database database
vault secrets enable -path=pki pki
vault secrets enable -path=transit transit

echo ">>> Enabling auth methods..."
vault auth enable kubernetes
vault auth enable aws

echo ">>> Configuring Kubernetes auth..."
vault write auth/kubernetes/config \
  kubernetes_host="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

echo ">>> Creating app policies..."
cat > /tmp/app-policy.hcl << 'POLICY'
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}
path "database/creds/app-role" {
  capabilities = ["read"]
}
path "transit/decrypt/app-key" {
  capabilities = ["update"]
}
POLICY

vault policy write app-policy /tmp/app-policy.hcl

echo ">>> Creating Kubernetes roles..."
vault write auth/kubernetes/role/app \
  bound_service_account_names=app-sa \
  bound_service_account_namespaces="dev,staging,prod" \
  policies=app-policy \
  ttl=1h

echo ">>> Vault configuration complete!"
