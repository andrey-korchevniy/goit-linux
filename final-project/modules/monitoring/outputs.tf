output "grafana_admin_user" {
  description = "Grafana default admin user"
  value       = "admin"
}

output "grafana_admin_password" {
  description = "Grafana admin password (from values)"
  value       = "admin123"
}

output "grafana_service_name" {
  description = "Service name for Grafana"
  value       = "grafana"
}

output "prometheus_service_name" {
  description = "Service name for Prometheus"
  value       = "prometheus-kube-prometheus-prometheus"
}



