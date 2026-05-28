package kubernetes.admission

# ─── DENY RULES ─────────────────────────────────────────────

# Deny containers running as root
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("Container '%v' must set runAsNonRoot: true", [container.name])
}

# Deny privileged containers
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Container '%v' must not run as privileged", [container.name])
}

# Deny containers without resource limits
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container '%v' must set memory limits", [container.name])
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container '%v' must set CPU limits", [container.name])
}

# Deny latest image tag
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container '%v' must not use 'latest' tag", [container.name])
}

# Deny host network
deny[msg] {
  input.kind == "Deployment"
  input.spec.template.spec.hostNetwork == true
  msg := "Deployment must not use host network"
}

# Deny host PID
deny[msg] {
  input.kind == "Deployment"
  input.spec.template.spec.hostPID == true
  msg := "Deployment must not use host PID"
}

# Deny allowPrivilegeEscalation
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Container '%v' must set allowPrivilegeEscalation: false", [container.name])
}

# Require readOnlyRootFilesystem
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.readOnlyRootFilesystem
  msg := sprintf("Container '%v' must set readOnlyRootFilesystem: true", [container.name])
}

# Deny missing liveness/readiness probes
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.livenessProbe
  msg := sprintf("Container '%v' must have a liveness probe", [container.name])
}
