resource "helm_release" "kube_prometheus" {
  name             = var.name
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}



