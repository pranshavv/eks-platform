# ── ArgoCD Helm Install ──────────────────────────────────────────────────────
# Installs ArgoCD onto the cluster via Helm
# Runs in its own namespace — completely isolated from app workloads

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3"

  create_namespace = true

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "500m"
          memory: "512Mi"
    controller:
      resources:
        requests:
          cpu: "250m"
          memory: "256Mi"
        limits:
          cpu: "500m"
          memory: "512Mi"
    repoServer:
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "250m"
          memory: "256Mi"
    EOT
  ]

  depends_on = [var.depends_on_eks]
}

# ── ArgoCD Root App ──────────────────────────────────────────────────────────
# This is the App-of-Apps pattern
# One root app watches argocd/apps/ folder
# It automatically creates child apps for backend, frontend, postgres

resource "kubectl_manifest" "argocd_root_app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: root-app
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/pranshavv/eks-platform.git
        targetRevision: main
        path: argocd/apps
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
  YAML

  depends_on = [helm_release.argocd]
}