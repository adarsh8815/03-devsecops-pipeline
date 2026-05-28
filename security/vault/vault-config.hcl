# HashiCorp Vault Configuration - Production Setup

storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-1"
  
  retry_join {
    leader_api_addr = "https://vault-node-2:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-node-3:8200"
  }
}

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/vault/tls/vault.crt"
  tls_key_file       = "/vault/tls/vault.key"
  tls_min_version    = "tls12"
  tls_cipher_suites  = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
}

seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "alias/vault-unseal-key"
}

api_addr     = "https://vault.internal.company.com:8200"
cluster_addr = "https://vault.internal.company.com:8201"
ui           = true

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}

log_level  = "info"
log_format = "json"
