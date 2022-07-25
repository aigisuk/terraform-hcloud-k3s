output "local_agent_nodepools" {
  description = "Configuration of provisioned agent nodepools"
  value       = local.agent_nodes
}

output "kubeconfig" {
  description = "Cluster default kubeconfig"
  value       = local.kubeconfig
  sensitive   = true
}