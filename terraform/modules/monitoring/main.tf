# ── Prometheus + Grafana ─────────────────────────────────────────────────────
# kube-prometheus-stack installs both in one chart
# Includes: Prometheus, Grafana, AlertManager, node-exporter, kube-state-metrics

resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.2"

  create_namespace = true

  values = [
    <<-EOT
    grafana:
      enabled: true
      adminPassword: "admin123"
      service:
        type: ClusterIP
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "250m"
          memory: "256Mi"

    prometheus:
      prometheusSpec:
        retention: 7d
        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "500m"
            memory: "1Gi"
        # scrape your app's /metrics endpoint
        additionalScrapeConfigs:
          - job_name: inventory-backend
            static_configs:
              - targets:
                  - backend-service.inventory.svc.cluster.local:80
            metrics_path: /metrics

    alertmanager:
      enabled: true
      alertmanagerSpec:
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "100m"
            memory: "128Mi"

    nodeExporter:
      enabled: true

    kubeStateMetrics:
      enabled: true

    defaultRules:
      create: true
      rules:
        alertmanager: true
        etcd: false
        nodeExporter: true
        kubeScheduler: false
    EOT
  ]

  depends_on = [var.depends_on_eks]
}