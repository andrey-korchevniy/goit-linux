variable "name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "kube-prometheus"
}

variable "namespace" {
  description = "K8s namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}



