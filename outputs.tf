output "local_agent_nodepools" {
  value = local.agent_nodes
}

output "kubeconfig" {
  description = "Kube Config for cluster"
  value       = local.kubeconfig
  sensitive   = true
}