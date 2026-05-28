# 🔒 Project 3: DevSecOps Pipeline - Shift Left Security

[![Security Score](https://img.shields.io/badge/Security-A+-green)](https://github.com)
[![OWASP](https://img.shields.io/badge/OWASP-Top10-red)](https://owasp.org)

## 🛡️ Security Stages Pipeline

```
Code Push
   │
   ▼
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: SAST (Static Analysis)                             │
│   CodeQL + Semgrep → SARIF → GitHub Security Tab           │
├─────────────────────────────────────────────────────────────┤
│ STAGE 2: Secret Detection                                    │
│   TruffleHog + GitLeaks → Block on verified secrets        │
├─────────────────────────────────────────────────────────────┤
│ STAGE 3: SCA (Software Composition Analysis)                 │
│   Safety + pip-audit + Snyk → CVE scanning                 │
├─────────────────────────────────────────────────────────────┤
│ STAGE 4: Container Security                                  │
│   Hadolint (Dockerfile) + Trivy + Grype → Image scanning   │
├─────────────────────────────────────────────────────────────┤
│ STAGE 5: Policy Enforcement                                  │
│   OPA/Rego → K8s manifest validation (12 security rules)   │
├─────────────────────────────────────────────────────────────┤
│ STAGE 6: DAST (Dynamic Testing)                              │
│   OWASP ZAP Baseline Scan → Running application            │
├─────────────────────────────────────────────────────────────┤
│ STAGE 7: Compliance                                          │
│   SBOM generation (SPDX format) + Artifact signing         │
└─────────────────────────────────────────────────────────────┘
   │
   ▼
 Deploy (only if all gates pass)
```

## 🛠️ Tools Used

| Tool | Stage | Purpose |
|------|-------|---------|
| CodeQL | SAST | Semantic code analysis |
| Semgrep | SAST | Pattern-based scanning |
| TruffleHog | Secrets | Verified secret detection |
| GitLeaks | Secrets | Pre-commit secret scanning |
| Safety + pip-audit | SCA | Python dependency CVEs |
| Snyk | SCA | Comprehensive SCA |
| Hadolint | Container | Dockerfile best practices |
| Trivy | Container | CVE + misconfiguration scan |
| Grype | Container | Anchore vulnerability scan |
| OPA/Rego | Policy | K8s admission control |
| OWASP ZAP | DAST | Dynamic web testing |
| HashiCorp Vault | Secrets Mgmt | Runtime secrets |
| Cosign | Signing | Image signing (Sigstore) |

## 🏛️ OPA Policies (12 Rules Enforced)

```rego
# All containers must:
✅ Run as non-root (runAsNonRoot: true)
✅ No privileged mode
✅ Set memory + CPU limits
✅ No latest image tag
✅ No host network/PID
✅ No allowPrivilegeEscalation
✅ readOnlyRootFilesystem: true
✅ Drop ALL capabilities
✅ Have liveness + readiness probes
✅ Labels: app, version, env
```

## 🚀 Quick Start

```bash
# Run full security scan locally
docker run --rm -v $(pwd):/app aquasec/trivy fs /app

# Run OPA policy check
opa eval -d security/opa/k8s-security.rego \
  -i k8s/deployment.yaml "data.kubernetes.admission.deny"

# Setup Vault locally
docker-compose -f docker-compose.vault.yml up -d
./security/vault/setup-vault.sh
```

## 📚 Learning Objectives

1. ✅ SAST/DAST/SCA - full security testing types
2. ✅ Shift-left security philosophy
3. ✅ OPA/Rego policy as code
4. ✅ HashiCorp Vault secrets management
5. ✅ Container image signing with Cosign
6. ✅ SBOM generation (SPDX/CycloneDX)
7. ✅ Security findings in GitHub Security tab
