output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = module.hcloud_k3s.kubeconfig
  sensitive   = true
}