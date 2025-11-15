output "jenkins_admin_user" {
  value       = "admin"
  description = "Default Jenkins admin user"
}

output "jenkins_password_note" {
  value       = "If not using fixed value, run: kubectl get secret --namespace ${var.namespace} ${var.name} -o jsonpath={.data.jenkins-admin-password} | base64 -d"
  description = "Instruction to fetch Jenkins admin password"
}


