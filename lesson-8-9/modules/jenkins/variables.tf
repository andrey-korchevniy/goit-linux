variable "name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "namespace" {
  description = "K8s namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins chart version"
  type        = string
  default     = "5.6.2"
}


