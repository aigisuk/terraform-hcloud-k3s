output "local_agent_nodepools" {
  value = local.agent_nodes
}

output "kubeconfig" {
  description = "Cluster default kubeconfig"
  value       = local.kubeconfig
  sensitive   = true
}